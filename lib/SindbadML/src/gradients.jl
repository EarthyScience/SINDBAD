export ForwardDiffGrads
export gradsBatch!
export newVals
export get∇params
export train
export get_site_losses
export destructureNN

export gradsBatchDistributed!
export get∇paramsDistributed
export trainDistributed
export getSiteLossesDistributed

"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, args...)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - kwargs :: keyword arguments needed by the loss_function
"""
#@everywhere 
function ForwardDiffGrads(loss_function::F, vals::AbstractArray, args...) where {F}
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
function ForwardDiffGradsCfg(loss_function::F, vals::AbstractArray, args...; CHUNK_SIZE = 12) where {F}
    out = similar(vals)
    loss_tmp(x) = loss_function(x, args...)
    cfg = ForwardDiff.GradientConfig(loss_tmp, vals, ForwardDiff.Chunk{CHUNK_SIZE}());
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
    f_grads,
    up_params_now,
    models,
    xbatch,
    all_sites,
    output_data,
    forcing_data,
    obs_data,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=true) where {F}

    p = Progress(length(xbatch); desc="Computing batch grads...", color=:red, enabled=logging)
    for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tbl_params, xbatch, idx)
        site_location = name_to_id(site_name, all_sites)
        land_init = land_init_space[site_location[1][2]]
        loc_forcing, loc_output, loc_obs  = getLocDataObsN(output_data, forcing_data, obs_data, site_location) # check output order in original definition

        gg = ForwardDiffGrads(
            loss_function,
            new_vals,
            models,
            loc_forcing,
            forcing_one_timestep,
            DiffCache.(loc_output),
            land_init,
            tem,
            param_to_index,
            loc_obs,
            cost_options,
            constraint_method
            )
        f_grads[:, idx] = gg

        next!(p; showvalues=[(:site_name, site_name)])
    end
end

function gradsBatchDistributed!(
    loss_function::F,
    f_grads,
    up_params_now,
    models,
    xbatch,
    all_sites,
    output_data,
    forcing_data,
    obs_data,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=true) where {F}

#    p = Progress(length(xbatch); desc="Computing batch grads...", color=:yellow, enabled=logging)

    @sync @distributed for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tbl_params, xbatch, idx)
        site_location = name_to_id(site_name, all_sites)
        land_init = land_init_space[site_location[1][2]]
        loc_forcing, loc_output, loc_obs  = getLocDataObsN(output_data, forcing_data, obs_data, site_location) # check output order in original definition

        gg = ForwardDiffGrads(
            loss_function,
            new_vals,
            models,
            loc_forcing,
            forcing_one_timestep,
            DiffCache.(loc_output),
            land_init,
            tem,
            param_to_index,
            loc_obs,
            cost_options,
            constraint_method
            )
        f_grads[:, idx] = gg
        #next!(p)
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
    up_params_now,
    models,
    new_sites,
    all_sites,
    output_data,
    forcing_data,
    obs_data,
    tbl_params,
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=false) where {F}

    tot_loss = fill(NaN32, length(new_sites))
    p = Progress(length(new_sites); desc="Computing site losses...", color=:yellow, enabled=logging)

    for idx ∈ eachindex(new_sites)
        site_name, new_vals = scaledParams(up_params_now,  tbl_params, new_sites, idx)
        site_location = name_to_id(site_name, all_sites)
        land_init = land_init_space[site_location[1][2]]

        loc_forcing, loc_output, loc_obs  = getLocDataObsN(output_data, forcing_data, obs_data, site_location)

        loss_site = loss_function(
            new_vals,
            models,
            loc_forcing,
            forcing_one_timestep,
            loc_output,
            land_init,
            tem,
            param_to_index,
            loc_obs,
            cost_options,
            constraint_method
            )

        tot_loss[idx] = loss_site
        next!(p; showvalues=[(:site_name, site_name)])
    end
    return tot_loss
end

function get_site_lossesDistributed(
    loss_function::F,
    up_params_now,
    models,
    new_sites,
    all_sites,
    output_data,
    forcing_data,
    obs_data,
    tbl_params,
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    logging=false) where {F}

    tot_loss = SharedArray{Float32}(length(new_sites))
    
    #p = Progress(length(new_sites); desc="Computing site losses...", color=:yellow, enabled=logging)

    @sync @distributed for idx ∈ eachindex(new_sites)
        site_name, new_vals = scaledParams(up_params_now,  tbl_params, new_sites, idx)
        site_location = name_to_id(site_name, all_sites)
        land_init = land_init_space[site_location[1][2]]

        loc_forcing, loc_output, loc_obs  = getLocDataObsN(output_data, forcing_data, obs_data, site_location)

        loss_site = loss_function(
            new_vals,
            models,
            loc_forcing,
            forcing_one_timestep,
            loc_output,
            land_init,
            tem,
            param_to_index,
            loc_obs,
            cost_options,
            constraint_method
            )

        tot_loss[idx] = loss_site
        #next!(p; showvalues=[(:site_name, site_name)])
    end
    return tot_loss
end


function train(
    init_model::Flux.Chain,
    loss_function::F,
    xfeatures,
    models,
    all_sites,
    output_data,
    forcing_data,
    obs_data,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    nepochs=2,
    opt = Optimisers.Adam(),
    bs_seed = 123,
    bs = 4,
    shuffle=true,
    local_root = nothing,
    name="seq_training_output") where {F}

    local_root = isnothing(local_root) ? dirname(Base.active_project()) : local_root
    f_path = joinpath(local_root, name)
    mkpath(f_path)

    sites = xfeatures.site
    flat, re, opt_state = destructureNN(init_model; nn_opt = opt)
    n_params = length(init_model[end].bias)

    xbatches = batch_shuffle(sites, bs; seed=123)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)
    
    p = Progress(nepochs; desc="Computing epochs...")

    for epoch ∈ 1:nepochs
        xbatches = shuffle ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches
        for xbatch ∈ xbatches
            
            f_grads = zeros(Float32, n_params, length(xbatch))

            x_feat = xfeatures(; site=xbatch)
            inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)
            gradsBatch!(
                loss_function,
                f_grads,
                inst_params,
                models,
                xbatch,
                all_sites,
                output_data,
                forcing_data,
                obs_data,
                tbl_params, 
                land_init_space,
                forcing_one_timestep,
                tem,
                param_to_index,
                cost_options,
                constraint_method;
                logging=false
                )

            _, ∇params = pb(f_grads)
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end

        up_params_now = re(flat)(xfeatures(; site=new_sites))

        loss_now = get_site_losses(
                loss_function,
                up_params_now,
                models,
                new_sites,
                all_sites,
                output_data,
                forcing_data,
                obs_data,
                tbl_params,
                land_init_space,
                forcing_one_timestep,
                tem,
                param_to_index,
                cost_options,
                constraint_method;
                logging=false
                )
        jldsave(joinpath(f_path, "$(name)_epoch_$(epoch).jld2"); loss = loss_now, re=re, flat=flat)
        tot_loss[:, epoch] = loss_now # fill(epoch,length(new_sites)) 
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return tot_loss, re, flat
end

function trainDistributed(
    init_model::Flux.Chain,
    loss_function::F,
    xfeatures,
    models,
    all_sites,
    output_data,
    forcing_data,
    obs_data,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    nepochs=2,
    opt = Optimisers.Adam(),
    bs_seed = 123,
    bs = 4,
    shuffle=true,
    local_root = nothing,
    name="par_training_output") where {F}

    local_root = isnothing(local_root) ? dirname(Base.active_project()) : local_root
    f_path = joinpath(local_root, name)
    mkpath(f_path)

    sites = xfeatures.site
    flat, re, opt_state = destructureNN(init_model; nn_opt = opt)
    n_params = length(init_model[end].bias)

    xbatches = batch_shuffle(sites, bs; seed=123)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)
    
    p = Progress(nepochs; desc="Computing epochs...")

    for epoch ∈ 1:nepochs
        xbatches = shuffle ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches
        for xbatch ∈ xbatches
            f_grads = SharedArray{Float32}(n_params, length(xbatch))
            x_feat = xfeatures(; site=xbatch)

            inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)
            gradsBatchDistributed!(
                loss_function,
                f_grads,
                inst_params,
                models,
                xbatch,
                all_sites,
                output_data,
                forcing_data,
                obs_data,
                tbl_params, 
                land_init_space,
                forcing_one_timestep,
                tem,
                param_to_index,
                cost_options,
                constraint_method;
                logging=false)

            _, ∇params = pb(f_grads)
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end
        up_params_now = re(flat)(xfeatures(; site=new_sites))
        loss_now = get_site_lossesDistributed(
                loss_function,
                up_params_now,
                models,
                new_sites,
                all_sites,
                output_data,
                forcing_data,
                obs_data,
                tbl_params,
                land_init_space,
                forcing_one_timestep,
                tem,
                param_to_index,
                cost_options,
                constraint_method;
                logging=false
                )

        jldsave(joinpath(f_path, "$(name)_epoch_$(epoch).jld2"); loss = loss_now, re=re, flat=flat)
        tot_loss[:, epoch] = loss_now # fill(epoch,length(new_sites)) 
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return tot_loss, re, flat
end