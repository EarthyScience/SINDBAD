export ForwardDiffGrads
export gradsBatch!
export newVals
export get∇params
export train
export get_site_losses
export destructureNN


"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, args...)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - kwargs :: keyword arguments needed by the loss_function
"""
#@everywhere 
function ForwardDiffGrads(loss_function::F, vals::AbstractArray, args...) where {F}
    #println("Starting grads comp")
    loss_tmp(x) = loss_function(x, args...)
    return ForwardDiff.gradient(loss_tmp, vals)
end

"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, args...; CHUNK_SIZE = 42)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - CHUNK_SIZE :: https://juliadiff.org/ForwardDiff.jl/dev/user/advanced/#Configuring-Chunk-Size
    - kwargs :: keyword arguments needed by the loss_function
"""
function ForwardDiffGradsCfg(loss_function::F, vals::AbstractArray, args...; CHUNK_SIZE=12) where {F}
    out = similar(vals)
    loss_tmp(x) = loss_function(x, args...)
    cfg = ForwardDiff.GradientConfig(loss_tmp, vals, ForwardDiff.Chunk{CHUNK_SIZE}())
    ForwardDiff.gradient!(out, loss_tmp, vals, cfg)
    return out
end

"""
    scaledParams(up_params_now, xbatch, idx)

Returns:
    - site_name
    - scaled parameters within the proper bounds
"""
function scaledParams(up_params_now, tblParams, xbatch, idx)
    site_name = xbatch[idx]
    x_params = up_params_now(; site=site_name)
    scaled_params = getParamsAct(x_params, tblParams)
    return site_name, scaled_params
end

function gradsBatch!(
    loss_function::F,
    grads_batch,
    scaled_params_batch,
    models,
    sites_batch,
    indices_batch,
    sites_forcing,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    loc_outputs,
    land_one,
    loc_observations,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=true) where {F}

    # indices_batch = name_to_id.(sites_batch, Ref(sites_forcing))
    # params_batch = params_sites(; site=sites_batch)
    # scaled_params_batch = getParamsAct(params_batch, tbl_params)

    p = Progress(length(sites_batch); desc="Computing batch grads...", color=:yellow, enabled=logging)
    @sync begin
        for idx ∈ eachindex(indices_batch)
           Threads.@spawn begin
                site_location = indices_batch[idx]
                site_name = sites_forcing[site_location]
                loc_params = scaled_params_batch(site=site_name)
                loc_forcing = loc_forcings[site_location]
                loc_obs = loc_observations[site_location]
                loc_output = loc_outputs[site_location]
                loc_spinup_forcing = loc_spinup_forcings[site_location]

                gg = ForwardDiffGrads(
                    loss_function,
                    loc_params,
                    models,
                    loc_forcing,
                    loc_spinup_forcing,
                    forcing_one_timestep,
                    DiffCache.(loc_output),
                    land_one,
                    tem,
                    param_to_index,
                    loc_obs,
                    cost_options,
                    constraint_method
                )
                grads_batch[:, idx] = gg
                next!(p)
           end
        end
    end
end


"""
    destructureNN(model; nn_opt=Optimisers.Adam())
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end

function get_site_losses(
    loss_function::F,
    sites_loss,
    epoch_number,
    scaled_params,
    models,
    indices_sites,
    sites_forcing,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    loc_outputs,
    land_one,
    loc_observations,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=true) where {F}


    p = Progress(size(sites_loss,1); desc="Computing batch grads...", color=:yellow, enabled=logging)
    @sync begin
        for idx ∈ eachindex(indices_sites)
            Threads.@spawn begin
                site_location = indices_sites[idx]
                site_name = sites_forcing[site_location]
                loc_params = scaled_params(site=site_name)
                loc_forcing = loc_forcings[site_location]
                loc_obs = loc_observations[site_location]
                loc_output = loc_outputs[site_location]
                loc_spinup_forcing = loc_spinup_forcings[site_location]

                gg = loss_function(
                    loc_params,
                    models,
                    loc_forcing,
                    loc_spinup_forcing,
                    forcing_one_timestep,
                    loc_output,
                    land_one,
                    tem,
                    param_to_index,
                    loc_obs,
                    cost_options,
                    constraint_method
                )
                sites_loss[idx, epoch_number] = gg
                next!(p)
            end
        end
    end
end


function train(
    nn_model_params::Flux.Chain,
    loss_function::F,
    xfeatures,
    models_lt,
    sites_forcing,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    loc_outputs,
    land_init,
    loc_observations,
    tbl_params,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    nepochs=2,
    opt=Optimisers.Adam(),
    bs_seed=123,
    bs=4,
    shuffle=true,
    local_root=nothing,
    name="seq_training_output") where {F}

    local_root = isnothing(local_root) ? dirname(Base.active_project()) : local_root
    f_path = joinpath(local_root, name)
    mkpath(f_path)

    sites_feature = xfeatures.site    
    intersect_sites = intersect(sites_feature, sites_forcing)
    sites_feature = intersect_sites

    indices_sites_feature = name_to_id.(sites_feature, Ref(sites_forcing))
    flat, re, opt_state = destructureNN(nn_model_params; nn_opt=opt)
    n_params = length(nn_model_params[end].bias)

    sites_batches = batch_shuffle(sites_feature, bs; seed=bs_seed)
    sites_loss = fill(NaN32, length(sites_feature), nepochs)

    p = Progress(nepochs; desc="Computing epochs...")


    for epoch ∈ 1:nepochs
        sites_batches_epoch = shuffle ? batch_shuffle(sites_feature, bs; seed=epoch + bs_seed) : sites_batches
        for sites_batch ∈ sites_batches_epoch

            grads_batch = zeros(Float32, n_params, length(sites_batch))
            x_feature_batch = xfeatures(; site=sites_batch)
            site_indices_batch = name_to_id.(sites_batch, Ref(sites_forcing))

            new_params, pb = Zygote.pullback(p -> re(p)(x_feature_batch), flat)            
            scaled_params_batch = getParamsAct(new_params, tbl_params)

            gradsBatch!(
                loss_function,
                grads_batch,
                scaled_params_batch,
                models_lt,
                sites_batch,
                site_indices_batch,
                sites_forcing,
                loc_forcings,
                loc_spinup_forcings,
                forcing_one_timestep,
                loc_outputs,
                land_init,
                loc_observations,
                tem,
                param_to_index,
                cost_options,
                constraint_method;
                logging=false
            )
            
            grads_batch = mean(grads_batch, dims=2)[:,1]
            ∇params = pb(grads_batch)[1]
            
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end

        params_epoch = re(flat)(xfeatures(; site=sites_feature))
        scaled_params_epoch = getParamsAct(params_epoch, tbl_params)


        get_site_losses(
            loss_function,
            sites_loss,
            epoch,
            scaled_params_epoch,
            models_lt,
            indices_sites_feature,
            sites_forcing,
            loc_forcings,
            loc_spinup_forcings,
            forcing_one_timestep,
            loc_outputs,
            land_init,
            loc_observations,
            tem,
            param_to_index,
            cost_options,
            constraint_method;
            logging=false
        )
        jldsave(joinpath(f_path, "$(name)_epoch_$(epoch).jld2"); loss= sites_loss[:, epoch], re=re, flat=flat)
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return sites_loss, re, flat
end
