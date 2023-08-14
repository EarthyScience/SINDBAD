export get_loc_loss
export loc_loss
export loc_loss_inner

"""
get_loc_loss(new_apps, loc_output, loc_obs, loc_forcing, loc_land_init, tem_helpers, tem_spinup, tem_models, tem_optim, f_one)
"""
function get_loc_loss(
    new_apps,
    loc_output,
    loc_obs,
    loc_forcing,
    loc_land_init,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)
    coreEcosystem!(loc_output,
        new_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        f_one)

    lossVec = getLossVectorArray(loc_obs, loc_output, tem_optim.cost_options)
    t_loss = combineLossArray(lossVec, Val{:sum}())
    return t_loss
end


"""
loc_loss(up_params,
    forward,
    tblParams,
    loc_output,
    loc_obs,
    loc_forcing,
    loc_land_init,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)
"""
function loc_loss(up_params,
    forward,
    tblParams,
    loc_output,
    loc_obs,
    loc_forcing,
    loc_land_init,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)

    new_apps = updateModelParametersType(tblParams, forward, up_params)
    return get_loc_loss(new_apps,
        loc_output,
        loc_obs,
        loc_forcing,
        loc_land_init,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_optim,
        f_one)
end

"""
    loc_loss_inner(up_params,
        loc_land_init,
        site_location,
        out_data,
        forc,
        obs,
        forward,
        tblParams,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_optim,
        f_one)
"""
function loc_loss_inner(up_params,
    loc_land_init,
    site_location,
    out_data,
    forc,
    obs,
    forward,
    tblParams,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)

    out_data = get_tmp.(out_data, (up_params,))
    new_apps = updateModelParametersType(tblParams, forward, up_params)
    loc_forcing, loc_output, loc_obs = getLocDataObsN(out_data, forc, obs, site_location)
    return get_loc_loss(new_apps,
        loc_output,
        loc_obs,
        loc_forcing,
        loc_land_init,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_optim,
        f_one)
end

# simpler forms

"""
    getSiteLoss(inits, data, data_optim, tem)

- inits = (; init_land, approaches)
- data = (; allocated_output, site_forcings)
- data_optim = (; site_obs, site_covariates)
- tem = (; helpers, spinup, models, optim, f_one)
"""

function getSiteLoss(inits, data, data_optim, tem) 
    coreEcosystem!(inits..., data..., tem...)
    lossVec = getLossVectorArray(data_optim.site_obs, data.allocated_output, tem.optim.cost_options)
    t_loss = combineLossArray(lossVec, Val{:sum}())
    return t_loss
end

function siteLossInner(up_params, inits, data_cache, data_optim, tem, tblParams)
    out_data = get_tmp.(data_cache.allocated_output, (up_params,))
    new_apps = updateModelParametersType(tblParams, inits.approaches, up_params)
    inits = (; inits..., approaches = new_apps)
    data = (; allocated_output = out_data, site_forcings)
    return getSiteLoss(inits, data, data_optim, tem)
end


function gradsBatch!(loss_function::Function, up_params_now, f_grads, xbatch, sites_f, data, data_optim,
    tem, tblParams, land_init_space, approaches; logging=true)

    p = Progress(length(xbatch); desc="Computing batch grads...", offset=1, color=:yellow, enabled=logging)
    for idx ∈ eachindex(xbatch)

        site_name, new_vals = scaledParams(up_params_now, tblParams, xbatch, idx)
        site_location = name_to_id(site_name, sites_f)
        init_land = land_init_space[site_location[1][2]]

        loc_output, loc_forcing, loc_obs = getLocDataObsN(data..., data_optim.site_obs, site_location) # check output order in original definition

        inits = (; init_land, approaches)
        data_optim = (; site_obs = loc_obs, )
        data_cache = (; allocated_output = DiffCache.(loc_output), site_forcings= loc_forcing)

        gg = ForwardDiffGrads(loss_function, new_vals, inits, data_cache, data_optim, tem, tblParams)
        f_grads[:, idx] = gg

        next!(p; showvalues=[(:site_name, site_name)])
    end
end


tem = (;
    tem_helpers,
    tem_models,
    tem_spinup,
    tem_run_spinup = tem_helpers.run.spinup.spinup_TEM,
)

optim = (;
    cost_options,
    multiconstraint_method
)

data = (;
    loc_forcing,
    forcing_one_timestep,
    allocated_output = loc_output
)

inits = (;
    selected_models,
    land_init
)
function getSiteLossTEM(inits, data, data_optim, tem, optim) 
    coreTEM!(inits.selected_models, data..., inits.land_init, tem...)
    lossVec = getLossVector(data_optim.site_obs, data.allocated_output, optim.cost_options)
    t_loss = combineLossArray(lossVec, optim.multiconstraint_method)
    return t_loss
end

loc_forcing, loc_output, loc_obs = getLocDataObsN(output_array, forc, obs_array, site_location)


inits = (; inits..., approaches = new_apps)
data = (; allocated_output = out_data, site_forcings)
return getSiteLoss(inits, data, data_optim, tem)