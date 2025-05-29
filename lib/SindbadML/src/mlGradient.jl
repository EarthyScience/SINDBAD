export gradientSite
export gradientBatch!
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
    
    sites_training, indices_sites_training, xfeatures, parameter_table, batch_size, chunk_size, metadata_global = train_refs
    sites_validation, indices_sites_validation, sites_testing, indices_sites_testing = test_val_refs

    lossSite, getInnerArgs = loss_fargs
    flat, re, opt_state = destructureNN(nn_model; nn_opt=optimizer)
    n_params = length(nn_model[end].bias)

    loss_training = fill(zero(Float32), length(sites_training), n_epochs)
    loss_validation = fill(zero(Float32), length(sites_validation), n_epochs)
    loss_testing = fill(zero(Float32), length(sites_testing), n_epochs)
    # ? save also the individual losses
    loss_split_training = fill(NaN32, length(sites_training), total_constraints, n_epochs)
    loss_split_validation = fill(NaN32, length(sites_validation), total_constraints, n_epochs)
    loss_split_testing = fill(NaN32, length(sites_testing), total_constraints, n_epochs)

    path_checkpoint = joinpath(path_experiment, "checkpoint")
    f_path = mkpath(path_checkpoint)

    @showprogress desc="training..." for epoch ∈ 1:n_epochs
        x_batches, idx_xbatches = batchShuffler(sites_training, indices_sites_training, batch_size; bs_seed=epoch)

        for (sites_batch, indices_sites_batch) in zip(x_batches, idx_xbatches)
            
            grads_batch = zeros(Float32, n_params, length(sites_batch))
            x_feat_batch = xfeatures(; site=sites_batch)
            new_params, pullback_func = getPullback(flat, re, x_feat_batch)
            _params_batch = getParamsAct(new_params, parameter_table)

            input_args = (_params_batch, forward_args..., indices_sites_batch, sites_batch)
            gradientBatch!(grads_lib, grads_batch, chunk_size, lossSite, getInnerArgs, input_args...)
            gradsNaNCheck!(grads_batch, _params_batch, sites_batch, parameter_table) #? checks for NaNs and if any replace them with 0.0f0
            # Jacobian-vector product
            ∇params = pullback_func(grads_batch)[1]
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end
        # calculate losses for all sites!
        _params_epoch = re(flat)(xfeatures)
        params_epoch = getParamsAct(_params_epoch, parameter_table)
        getLossForSites(grads_lib, lossSite, loss_training, loss_split_training, epoch, params_epoch, sites_training, indices_sites_training, forward_args...)
        # ? validation
        getLossForSites(grads_lib, lossSite, loss_validation, loss_split_validation, epoch, params_epoch, sites_validation, indices_sites_validation, forward_args...)
        # ? test 
        getLossForSites(grads_lib, lossSite, loss_testing, loss_split_testing, epoch, params_epoch, sites_testing, indices_sites_testing, forward_args...)

        jldsave(joinpath(f_path, "checkpoint_epoch_$(epoch).jld2");
            lower_bound=parameter_table.lower, upper_bound=parameter_table.upper, ps_names=parameter_table.name,
            parameter_table=parameter_table,
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


# https://juliateachingctu.github.io/Scientific-Programming-in-Julia/dev/lecture_08/lecture/
"""
    gradientSite(grads_lib, x_vals, chunk_size::Int, loss_f::Function, args...)
    gradientSite(grads_lib, x_vals, gradient_options::NamedTuple, loss_f::Function)
    gradientSite(grads_lib, x_vals::AbstractArray, gradient_options::NamedTuple, loss_f::Function)

Compute gradients of the loss function with respect to model parameters for a single site using the specified gradient library.

This function dispatches on the type of `grads_lib` to select the appropriate differentiation backend (e.g., `PolyesterForwardDiff`, `ForwardDiff`, `FiniteDiff`, `FiniteDifferences`, `Zygote`, or `Enzyme`). It supports both threaded and single-threaded computation, as well as chunked evaluation for memory and speed trade-offs.

# Arguments
- `grads_lib`: Gradient computation library or method. Supported types include:
    - `PolyesterForwardDiffGrad`: Uses `PolyesterForwardDiff.jl` for multi-threaded chunked gradients.
    - `ForwardDiffGrad`: Uses `ForwardDiff.jl` for automatic differentiation.
    - `FiniteDiffGrad`: Uses `FiniteDiff.jl` for finite difference gradients.
    - `FiniteDifferencesGrad`: Uses `FiniteDifferences.jl` for finite difference gradients.
    - `ZygoteGrad`: Uses `Zygote.jl` for reverse-mode automatic differentiation.
    - `EnzymeGrad`: Uses `Enzyme.jl` for AD (experimental).
- `x_vals`: Parameter values for which to compute gradients.
- `chunk_size`: (Optional) Chunk size for threaded gradient computation (used by `PolyesterForwardDiffGrad`).
- `gradient_options`: (Optional) NamedTuple of gradient options (e.g., chunk size).
- `loss_f`: Loss function to be differentiated.
- `args...`: Additional arguments to be passed to the loss function.

# Returns
- `∇x`: Array of gradients of the loss function with respect to `x_vals`.

# Notes
- On Apple M1 systems, `PolyesterForwardDiffGrad` falls back to single-threaded `ForwardDiff` due to closure issues.
- The function is used internally for both site-level and batch-level gradient computation in hybrid ML training.

# Example
```julia
grads = gradientSite(ForwardDiffGrad(), x_vals, (chunk_size=4,), loss_f)
```
"""
function gradientSite end

function gradientSite(grads_lib::PolyesterForwardDiffGrad, x_vals, chunk_size::Int, loss_f::F, args...) where {F}
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

function gradientSite(::PolyesterForwardDiffGrad, x_vals, gradient_options::NamedTuple, loss_f::F) where {F}
    ∇x = similar(x_vals) # pre-allocate
    if occursin("arm64-apple-darwin", Sys.MACHINE) # fallback due to closure issues on M1 systems
        # cfg = ForwardDiff.GradientConfig(loss_tmp, x_vals, Chunk{chunk_size}());
        ForwardDiff.gradient!(∇x, loss_f, x_vals) # ?, add `cfg` at the end if further control is needed.
    else
        PolyesterForwardDiff.threaded_gradient!(loss_f, ∇x, x_vals, ForwardDiff.Chunk(chunk_size));
    end
    return ∇x
end

function gradientSite(::ForwardDiffGrad, x_vals::AbstractArray, gradient_options::NamedTuple, loss_f::F) where {F}
    # cfg = ForwardDiff.GradientConfig(loss_f, x_vals, Chunk{gradient_options.chunk_size}());
    return ForwardDiff.gradient(loss_f, x_vals)
end

function gradientSite(::FiniteDiffGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    return FiniteDiff.finite_difference_gradient(loss_f, x_vals)
end

function gradientSite(::FiniteDifferencesGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    gr_fds = FiniteDifferences.grad(FiniteDifferences.central_fdm(5, 1), loss_f, x_vals)
    return gr_fds[1]
end

function gradientSite(::ZygoteGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    return Zygote.gradient(loss_f, x_vals)
end

function gradientSite(::EnzymeGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    # does not work with `Enzyme.gradient!` but is kept here as placeholder for future development
    # Ensure x_vals is a mutable array (Vector)
    x_vals = collect(copy(x_vals))  # Convert to a mutable array if necessary
    # x_vals = copy(x_vals)
    return Enzyme.gradient(Forward, loss_f, x_vals)
end

"""
    gradientBatch!(grads_lib, grads_batch, chunk_size::Int, loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
    gradientBatch!(grads_lib, grads_batch, gradient_options::NamedTuple, loss_functions, scaled_params_batch, sites_batch; showprog=false)

Compute gradients for a batch of samples in hybrid (ML) modeling in SINDBAD.

This function computes the gradients of the loss function with respect to model parameters for a batch of sites or samples, using the specified gradient library. It supports both distributed and multi-threaded execution, and can handle different gradient computation backends (e.g., `PolyesterForwardDiff`, `ForwardDiff`, `FiniteDiff`, etc.).

# Arguments
- `grads_lib`: Gradient computation library or method. Supported types include:
    - `PolyesterForwardDiffGrad`: Uses `PolyesterForwardDiff.jl` for multi-threaded chunked gradients.
    - Other `MLGradType` subtypes: Use their respective backend.
- `grads_batch`: Pre-allocated array for storing batched gradients (size: n_parameters × n_samples).
- `chunk_size`: (Optional) Chunk size for threaded gradient computation (used by `PolyesterForwardDiffGrad`).
- `gradient_options`: (Optional) NamedTuple of gradient options (e.g., chunk size).
- `loss_f`: Loss function to be applied (for all samples).
- `get_inner_args`: Function to obtain inner arguments for the loss function.
- `input_args`: Global input arguments for the batch.
- `loss_functions`: Array or KeyedArray of loss functions, one per site.
- `scaled_params_batch`: Callable or array providing scaled parameters for each site.
- `sites_batch`: List or array of site identifiers for the batch.
- `showprog`: (Optional) If `true`, display a progress bar during computation (default: `false`).

# Returns
- Updates `grads_batch` in-place with computed gradients for each sample in the batch.

# Notes
- The function automatically selects between distributed (`pmap`) and multi-threaded (`Threads.@spawn`) execution depending on the backend and arguments.
- Designed for use within training loops for efficient batch gradient computation.

# Example
```julia
gradientBatch!(grads_lib, grads_batch, (chunk_size=4,), loss_functions, scaled_params_batch, sites_batch; showprog=true)
```
"""
function gradientBatch! end


function gradientBatch!(grads_lib::PolyesterForwardDiffGrad, dx_batch, chunk_size::Int,
    loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
    mapfun = showprog ? progress_pmap : pmap
    result = mapfun(CachingPool(workers()), axes(dx_batch, 2)) do idx
        x_vals, inner_args = get_inner_args(idx, grads_lib, input_args...)
        gradientSite(grads_lib, x_vals, chunk_size, loss_f, inner_args...)
    end
    for idx in axes(dx_batch, 2)
        dx_batch[:, idx] = result[idx]
    end
end

function gradientBatch!(grads_lib::PolyesterForwardDiffGrad, dx_batch, gradient_options::NamedTuple, loss_functions, scaled_params_batch, sites_batch; showprog=false)
    mapfun = showprog ? progress_pmap : pmap
    result = mapfun(CachingPool(workers()), axes(dx_batch, 2)) do idx
        site_name = sites_batch[idx]
        loss_f = loss_functions(site=site_name)
        x_vals = scaled_params_batch(site=site_name).data.data
        gradientSite(grads_lib, x_vals, gradient_options, loss_f)    
    end
    for idx in axes(dx_batch, 2)
        dx_batch[:, idx] = result[idx]
    end
end

function gradientBatch!(grads_lib::MLGradType, grads_batch, gradient_options::NamedTuple, loss_functions, scaled_params_batch, sites_batch; showprog=false)
    # Threads.@spawn allows dynamic scheduling instead of static scheduling
    # of Threads.@threads macro.
    # See <https://github.com/JuliaLang/julia/issues/21017>

    p = Progress(length(axes(grads_batch,2)); desc="Computing batch grads...", color=:cyan, enabled=showprog)
    @sync begin
        for idx ∈ axes(grads_batch, 2)
            Threads.@spawn begin
                site_name = sites_batch[idx]
                loss_f = loss_functions(site=site_name)
                x_vals = scaled_params_batch(site=site_name).data.data
                gg = gradientSite(grads_lib, x_vals, gradient_options, loss_f)    
                grads_batch[:, idx] = gg
                next!(p)
            end
        end
    end
end

"""
    gradsNaNCheck!(grads_batch, _params_batch, sites_batch, parameter_table; show_params_for_nan=false)

Utility function to check if some calculated gradients were NaN (if found please double check your approach).
This function will replace those NaNs with 0.0f0.

# Arguments
- `grads_batch`: gradients array.
- `_params_batch`: parameters values.
- `sites_batch`: sites names.
- `parameter_table`: parameters table.
- `show_params_for_nan=false`: if true, it will show the parameters that caused the NaNs.
"""
function gradsNaNCheck!(grads_batch, _params_batch, sites_batch, parameter_table; replace_value = 0.0, show_params_for_nan=false)
    if sum(isnan.(grads_batch))>0
        if show_params_for_nan
            foreach(findall(x->isnan(x), grads_batch)) do ci
                p_index_tmp, si = Tuple(ci)
                site_name_tmp = sites_batch[si]
                p_vec_tmp = _params_batch(site=site_name_tmp)
                parameter_values =  Pair(parameter_table.name[p_index_tmp], (p_vec_tmp[p_index_tmp], parameter_table.lower[p_index_tmp], parameter_table.upper[p_index_tmp]))
                @info "site: $site_name_tmp, parameter: $parameter_values"
            end
        end
        @warn "NaNs in grads, replacing all by 0.0f0"
        replace!(grads_batch, NaN => eltype(grads_batch)(replace_value))
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