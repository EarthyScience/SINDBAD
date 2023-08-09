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