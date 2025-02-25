export gradientPolyester
export gradientBatchPolyester!
export mixedGradientTraining
export gradsNaNCheck!
export loadTrainedNN

"""
    mixedGradientTraining(grads_lib, nn_model, train_refs, test_val_refs, loss_fargs, forward_args; n_epochs=3, optimizer=Optimisers.Adam(), path_experiment="/")

Training function that computes model parameters using a neural network, which are then used by process-based models (PBMs) to estimate parameter gradients. Neural network weights are updated using the product of these gradients with the neural network's Jacobian.

# Arguments
- `grads_lib`: Library to compute PBMs parameter gradients.
- `nn_model`: A `Flux.Chain` neural network.
- `train_refs`: training data features.
- `test_val_refs`: test and validation data features.
- `loss_fargs`: functions used to calculate the loss.
- `forward_args`: arguments to evaluate the PBMs.
- `path_experiment="/"`: save model to path.

"""
function mixedGradientTraining(grads_lib, nn_model, train_refs, test_val_refs, total_constraints, loss_fargs, forward_args;
    n_epochs=3, optimizer=Optimisers.Adam(), path_experiment="/")
    
    sites_training, indices_sites_training, xfeatures, tbl_params, batch_size, chunk_size, metadata_global = train_refs
    sites_validation, indices_sites_validation, sites_testing, indices_sites_testing = test_val_refs

    lossSite, getInnerArgs = loss_fargs
    flat, re, opt_state = destructureNN(nn_model; nn_opt=optimizer)
    n_params = length(nn_model[end].bias)

    loss_training = fill(zero(Float32), length(sites_training), n_epochs)
    loss_validation = fill(zero(Float32), length(sites_validation), n_epochs)
    loss_testing = fill(zero(Float32), length(sites_testing), n_epochs)
    # ? save also the individual losses
    loss_split_training = fill(zero(Float32), length(sites_training), total_constraints, n_epochs)
    loss_split_validation = fill(zero(Float32), length(sites_validation), total_constraints, n_epochs)
    loss_split_testing = fill(zero(Float32), length(sites_testing), total_constraints, n_epochs)

    path_checkpoint = joinpath(path_experiment, "checkpoint")
    f_path = mkpath(path_checkpoint)

    @showprogress desc="training..." for epoch ∈ 1:n_epochs
        x_batches, idx_xbatches = batchShuffler(sites_training, indices_sites_training, batch_size; bs_seed=epoch)

        for (sites_batch, indices_sites_batch) in zip(x_batches, idx_xbatches)
            
            grads_batch = zeros(Float32, n_params, length(sites_batch))
            x_feat_batch = xfeatures(; site=sites_batch)
            new_params, pullback_func = Zygote.pullback(p -> re(p)(x_feat_batch), flat)            
            _params_batch = getParamsAct(new_params, tbl_params)

            input_args = (_params_batch, forward_args..., indices_sites_batch, sites_batch)
            gradientBatchPolyester!(grads_lib, grads_batch, chunk_size, lossSite, getInnerArgs, input_args...)
            gradsNaNCheck!(grads_batch, _params_batch, sites_batch, tbl_params) #? checks for NaNs and if any replace them with 0.0f0
            # Jacobian-vector product
            ∇params = pullback_func(grads_batch)[1]
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end
        # calculate losses for all sites!
        _params_epoch = re(flat)(xfeatures)
        params_epoch = getParamsAct(_params_epoch, tbl_params)
        getLossForSites(grads_lib, lossSite, loss_training, loss_split_training, epoch, params_epoch, sites_training, indices_sites_training, forward_args...)
        # ? validation
        getLossForSites(grads_lib, lossSite, loss_validation, loss_split_validation, epoch, params_epoch, sites_validation, indices_sites_validation, forward_args...)
        # ? test 
       getLossForSites(grads_lib, lossSite, loss_testing, loss_split_testing, epoch, params_epoch, sites_testing, indices_sites_testing, forward_args...)

        jldsave(joinpath(f_path, "checkpoint_epoch_$(epoch).jld2");
            lower_bound=tbl_params.lower, upper_bound=tbl_params.upper, ps_names=tbl_params.name,
            tbl_params=tbl_params,
            metadata_global=metadata_global,
            loss_training=loss_training[:, epoch],
            loss_validation=loss_validation[:, epoch],
            loss_testing=loss_testing[:, epoch],
            loss_split_training=loss_split_training[:,:, epoch],
            loss_split_validation=loss_split_validation[:,:, epoch],
            loss_split_testing=loss_split_testing[:,:, epoch],
            re=re,
            flat=flat)
    end
    return nothing
end

"""
    batchShuffler(x_forcings, ids_forcings, batch_size; bs_seed=1456)

Shuffles the batches of forcings and their corresponding indices.
"""
function batchShuffler(x_forcings, ids_forcings, batch_size; bs_seed=1456)
    x_batches = shuffleBatches(x_forcings, batch_size; seed=bs_seed)
    ids_batches = shuffleBatches(ids_forcings, batch_size; seed=bs_seed)
    return x_batches, ids_batches
end

"""
    gradientPolyester(grads_lib::ForwardDiffGrad, x_vals, chunk_size::Int, loss::F, args...)

Computes gradients using `PolyesterForwardDiff.jl` for multi-threaded chunk splits. The optimal speed is ideally achieved with `one thread` when `chunk_size=1` and `n-threads` for `n` parameters.
However, a good compromise between memory allocations and speed could be to set `chunk_size=3` and use `n-threads` for `2n parameters`.

# Arguments
- `grads_lib`: uses ForwardDiff.jl for gradients computation.
- `x_vals`: parameters values.
- `chunk_size`: Int, chunk size for PolyesterForwardDiff's threads.
- `loss_f`: loss function to be applied.
- `args...`: additional arguments for the loss function.

!!! warning
    For M1 systems we default to ForwardDiff.gradient! single-threaded. And we let the `GradientConfig` constructor to automatically select the appropriate `chunk_size`.

Returns: a `∇x` array with all parameter's gradients.
"""
function gradientPolyester(grads_lib::ForwardDiffGrad, x_vals, chunk_size::Int, loss_f::F, args...) where {F}
    loss_tmp(x) = loss_f(x, grads_lib, args...)
    ∇x = similar(x_vals) # pre-allocate
    if occursin("arm64-apple-darwin", Sys.MACHINE) # fallback due to closure issues on M1 systems
        # cfg = ForwardDiff.GradientConfig(loss_tmp, x_vals, Chunk{chunk_size}());
        ForwardDiff.gradient!(∇x, loss_tmp, x_vals) # ?, add `cfg` at the end if further control is needed.
    else
        PolyesterForwardDiff.threaded_gradient!(loss_tmp, ∇x, x_vals, ForwardDiff.Chunk(chunk_size));
    end
    return ∇x
end

"""
    gradientBatchPolyester!(grads_lib::ForwardDiffGrad, dx_batch, chunk_size::Int, loss_f::Function, get_inner_args::Function, input_args...; showprog=false)

# Computes gradients for a batch of samples.

# Arguments
- `grads_lib`: uses ForwardDiff.jl for gradients computation.
- `dx_batch`: pre-allocated array for batched gradients.
- `chunk_size`: Int, chunk size for PolyesterForwardDiff's threads.
- `loss_f`: loss function to be applied.
- `get_inner_args`: function to obtain inner values of loss function.
- `input_args`: global input arguments.

# Returns: 
A `n x m` matrix for `n parameters gradients` and `m` samples.

"""
function gradientBatchPolyester!(grads_lib::ForwardDiffGrad, dx_batch, chunk_size::Int,
    loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
    
    mapfun = showprog ? progress_pmap : pmap
    result = mapfun(CachingPool(workers()), axes(dx_batch, 2)) do idx
        x_vals, inner_args = get_inner_args(idx, grads_lib, input_args...)
        gradientPolyester(grads_lib, x_vals, chunk_size, loss_f, inner_args...)
    end
    for idx in axes(dx_batch, 2)
        dx_batch[:, idx] = result[idx]
    end
end

"""
    gradsNaNCheck!(grads_batch, _params_batch, sites_batch, tbl_params; show_params_for_nan=false)

Utility function to check if some calculated gradients were NaN (if found please double check your approach).
This function will replace those NaNs with 0.0f0.

# Arguments
- `grads_batch`: gradients array.
- `_params_batch`: parameters values.
- `sites_batch`: sites names.
- `tbl_params`: parameters table.
- `show_params_for_nan=false`: if true, it will show the parameters that caused the NaNs.
"""
function gradsNaNCheck!(grads_batch, _params_batch, sites_batch, tbl_params; show_params_for_nan=false)
    if sum(isnan.(grads_batch))>0
        if show_params_for_nan
            foreach(findall(x->isnan(x), grads_batch)) do ci
                p_index_tmp, si = ci
                site_name_tmp = sites_batch[si]
                p_vec_tmp = _params_batch(site=site_name_tmp)
                param_values =  Pair(tbl_params.name[p_index_tmp], (p_vec_tmp[p_index_tmp], tbl_params.lower[p_index_tmp], tbl_params.upper[p_index_tmp]))
                @info "site: $site_name_tmp, parameter: $param_values"
            end
        end
        @warn "NaNs in grads, replacing all by 0.0f0"
        replace!(grads_batch, NaN => 0.0f0)
    end
end

"""
    loadTrainedNN(path_model)

# Arguments
- `path_model`: path to the model.
"""
function loadTrainedNN(path_model)
    model_props = JLD2.load(path_model)
    return (;
        trainedNN=model_props["re"](model_props["flat"]), # ? model structure and trained weights
        lower_bound=model_props["lower_bound"],  # ? parameters' attributes    
        upper_bound=model_props["upper_bound"],
        ps_names=model_props["ps_names"],
        metadata_global=model_props["metadata_global"])
end