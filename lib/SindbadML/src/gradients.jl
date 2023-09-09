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
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, kwargs...)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - kwargs :: keyword arguments needed by the loss_function
"""
#@everywhere 
function ForwardDiffGrads(loss_function::Function, vals::AbstractArray, kwargs...)
    loss_tmp(x) = loss_function(x, kwargs...)
    return ForwardDiff.gradient(loss_tmp, vals)
end

"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, kwargs...; CHUNK_SIZE = 42)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - CHUNK_SIZE :: https://juliadiff.org/ForwardDiff.jl/dev/user/advanced/#Configuring-Chunk-Size
    - kwargs :: keyword arguments needed by the loss_function
"""
function ForwardDiffGradsCfg(loss_function::Function, vals::AbstractArray, kwargs...; CHUNK_SIZE = 12)
    out = similar(vals)
    loss_tmp(x) = loss_function(x, kwargs...)
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
    approaches,
    xbatch,
    sites_f,
    data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=true) where {F}

    p = Progress(length(xbatch); desc="Computing batch grads...", offset=0, color=:yellow, enabled=logging)
    for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tbl_params, xbatch, idx)
        site_location = name_to_id(site_name, sites_f)
        land_init = land_init_space[site_location[1][2]]
        loc_forcing, loc_output, loc_obs  = getLocDataObsN(data.allocated_output, data.forcing, data_optim.obs, site_location) # check output order in original definition

        inits = (; selected_models = approaches, land_init)
        data_optim_now = (; site_obs = loc_obs, )
        data_cache = (; loc_forcing, forcing_one_timestep, allocated_output = DiffCache.(loc_output))

        gg = ForwardDiffGrads(loss_function, new_vals, inits, data_cache, data_optim_now, tem, param_to_index, optim)
        f_grads[:, idx] = gg

        next!(p; showvalues=[(:site_name, site_name)])
    end
end

function gradsBatchDistributed!(
    loss_function::F,
    f_grads,
    up_params_now,
    approaches,
    xbatch,
    sites_f,
    data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=false) where {F}

    p = Progress(length(xbatch); desc="Computing batch grads...", color=:yellow, enabled=logging)
    @sync @distributed for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tbl_params, xbatch, idx)
        site_location = name_to_id(site_name, sites_f)
        land_init = land_init_space[site_location[1][2]]
        loc_forcing, loc_output, loc_obs  = getLocDataObsN(data.allocated_output, data.forcing, data_optim.obs, site_location) # check output order in original definition

        inits = (; selected_models = approaches, land_init)
        data_optim_now = (; site_obs = loc_obs, )
        data_cache = (; loc_forcing, forcing_one_timestep, allocated_output = DiffCache.(loc_output))

        gg = ForwardDiffGrads(loss_function, new_vals, inits, data_cache, data_optim_now, tem, param_to_index, optim)
        f_grads[:, idx] = gg
        next!(p)
    end
end

function get∇params(
    loss_function::F,
    xfeatures,
    n_params,
    re,
    flat,
    approaches,
    xbatch,
    sites_f,
    data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=false) where {F}

    f_grads = zeros(Float32, n_params, length(xbatch))
    x_feat = xfeatures(; site=xbatch)
    inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)


    gradsBatch!(loss_function,
        f_grads,
        inst_params,
        approaches,
        xbatch,
        sites_f,
        data,
        data_optim,
        tbl_params, 
        land_init_space,
        forcing_one_timestep,
        tem,
        param_to_index,
        optim;
        logging=logging
        )

    _, ∇params = pb(f_grads)
    return ∇params
end

function get∇paramsDistributed(
    loss_function::F,
    xfeatures,
    n_params,
    re,
    flat,
    approaches,
    xbatch,
    sites_f,
    data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=false) where {F}

    f_grads = SharedArray{Float32}(n_params, length(xbatch))

    x_feat = xfeatures(; site=xbatch)
    inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)

    gradsBatchDistributed!(loss_function,
        f_grads,
        inst_params,
        approaches,
        xbatch,
        sites_f,
        data,
        data_optim,
        tbl_params, 
        land_init_space,
        forcing_one_timestep,
        tem,
        optim;
        logging=logging
        )

    _, ∇params = pb(f_grads)
    return ∇params
end

"""
    destructureNN(model; nn_opt=Optimisers.Adam())
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end


"""
    train(init_model::Flux.Chain, loss_function::Function, xfeatures, kwargs...;
        nepochs=2, opt = Optimisers.Adam(), bs_seed = 123, bs = 4, shuffle=true)
"""
function train(
    init_model::Flux.Chain,
    loss_function::Function,
    xfeatures,
    approaches,
    sites_f,
    data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    nepochs=2,
    opt = Optimisers.Adam(),
    bs_seed = 123,
    bs = 4,
    shuffle=true,
    name="test_hybrid_seq",
    )

    sites = xfeatures.site
    flat, re, opt_state = destructureNN(init_model; nn_opt = opt)
    n_params = length(init_model[end].bias)

    xbatches = batch_shuffle(sites, bs; seed=123)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)
    
    p = Progress(nepochs; desc="Computing epochs...")

    for epoch ∈ 1:nepochs
        #xbatches = shuffle ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches
        for (batch_id, xbatch) ∈ enumerate(xbatches)
            ∇params = get∇params(
                loss_function,
                xfeatures,
                n_params,
                re,
                flat,
                approaches,
                xbatch,
                sites_f,
                data,
                data_optim,
                tbl_params, 
                land_init_space,
                forcing_one_timestep,
                tem,
                param_to_index,
                optim
            )

            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end

        up_params_now = re(flat)(xfeatures(; site=new_sites))
        loss_now = get_site_losses(
            loss_function,
            up_params_now,
            approaches,
            new_sites,
            sites_f,
            data,
            data_optim,
            tbl_params,
            land_init_space,
            forcing_one_timestep,
            tem,
            param_to_index,
            optim;
            logging=true
            )
        jldsave(joinpath(@__DIR__, "$(name)_epoch_$(epoch).jld2"); loss = loss_now, re=re, flat=flat)
        tot_loss[:, epoch] = loss_now
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return tot_loss, re, flat
end

"""
    train(init_model::Flux.Chain, loss_function::Function, xfeatures, kwargs...;
        nepochs=2, opt = Optimisers.Adam(), bs_seed = 123, bs = 4, shuffle=true)
"""
function trainDistributed(
    init_model::Flux.Chain,
    loss_function::Function,
    xfeatures,
    approaches,
    sites_f,
    data,
    data_optim,
    tbl_params, 
    land_init_space,
    forcing_one_timestep,
    tem,
    optim;
    nepochs=2,
    opt = Optimisers.Adam(),
    bs_seed = 123,
    bs = 4,
    shuffle=true,
    name="test_hybrid_distri",
    )

    sites = xfeatures.site
    flat, re, opt_state = destructureNN(init_model; nn_opt = opt)
    n_params = length(init_model[end].bias)

    xbatches = batch_shuffle(sites, bs; seed=123)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)

    p = Progress(nepochs; desc="Computing epochs...")
    for epoch ∈ 1:nepochs
        xbatches = shuffle ? batch_shuffle(sites, bs; seed=epoch + bs_seed) : xbatches

        for (batch_id, xbatch) ∈ enumerate(xbatches)
            ∇params = get∇paramsDistributed(
                loss_function,
                xfeatures,
                n_params,
                re,
                flat,
                approaches,
                xbatch,
                sites_f,
                data,
                data_optim,
                tbl_params, 
                land_init_space,
                forcing_one_timestep,
                tem,
                optim
            )

            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
        end

        up_params_now = re(flat)(xfeatures(; site=new_sites))
        loss_now = getSiteLossesDistributed(
            loss_function,
            up_params_now,
            approaches,
            new_sites,
            sites_f,
            data,
            data_optim,
            tbl_params,
            land_init_space,
            forcing_one_timestep,
            tem,
            optim;
            logging=true
            )
        jldsave(joinpath(@__DIR__, "$(name)_epoch_$(epoch).jld2"); loss = loss_now, re=re, flat=flat)
        tot_loss[:, epoch] = loss_now
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return tot_loss, re, flat
end

function get_site_losses(
    loss_function::F,
    up_params_now,
    approaches,
    new_sites,
    sites_f,
    data,
    data_optim,
    tbl_params,
    land_init_space,
    forcing_one_timestep,
    tem,
    param_to_index,
    optim;
    logging=false) where {F}

    tot_loss = fill(NaN32, length(new_sites))
    p = Progress(length(new_sites); desc="Computing site losses...", color=:yellow, enabled=logging)

    for idx ∈ eachindex(new_sites)
        site_name, new_vals = scaledParams(up_params_now,  tbl_params, new_sites, idx)
        site_location = name_to_id(site_name, sites_f)
        land_init = land_init_space[site_location[1][2]]

        loc_forcing, loc_output, loc_obs  = getLocDataObsN(data.allocated_output, data.forcing, data_optim.obs, site_location)
        
        inits = (;
            selected_models = approaches,
            land_init,
            )
        data_optim_now = (;
            site_obs = loc_obs,
            )
        data_tmp = (;
            loc_forcing,
            forcing_one_timestep,
            allocated_output = loc_output,
            )

        loss_site = loss_function(new_vals, inits, data_tmp, data_optim_now, tem, param_to_index, optim)
        tot_loss[idx] = loss_site
        next!(p; showvalues=[(:site_name, site_name)])
    end
    return tot_loss
end

function getSiteLossesDistributed(
    loss_function::Function,
    up_params_now,
    approaches,
    new_sites,
    sites_f,
    data,
    data_optim,
    tbl_params,
    land_init_space,
    forcing_one_timestep,
    tem,
    optim;
    logging=true
    )

    tot_loss = SharedArray{Float32}(length(new_sites)) # fill(NaN32, length(new_sites))
    #p = Progress(length(new_sites); desc="Computing site losses...", color=:yellow, enabled=logging)

    @sync @distributed for idx ∈ eachindex(new_sites)
        site_name, new_vals = scaledParams(up_params_now,  tbl_params, new_sites, idx)
        site_location = name_to_id(site_name, sites_f)
        land_init = land_init_space[site_location[1][2]]

        loc_forcing, loc_output, loc_obs  = getLocDataObsN(data.allocated_output, data.forcing, data_optim.obs, site_location)
        
        inits = (;
            selected_models = approaches,
            land_init,
            )
        data_optim_now = (;
            site_obs = loc_obs,
            )
        data_tmp = (;
            loc_forcing,
            forcing_one_timestep,
            allocated_output = loc_output,
            )

        loss_site = loss_function(new_vals, inits, data_tmp, data_optim_now, tem, tbl_params, optim)
        tot_loss[idx] = loss_site
        #next!(p; showvalues=[(:site_name, site_name)])
    end
    return tot_loss
end