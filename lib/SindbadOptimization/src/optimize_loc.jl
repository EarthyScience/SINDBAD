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

function get_site_losses(res_vec,
    out_vars,
    vars_cons,
    up_params_now,
    out_data,
    forc,
    obs_now,
    new_sites,
    sites_f,
    land_init_space,
    forward,
    tblParams,
    kwargs_fixed
)
    tot_loss = fill(NaN32, length(new_sites))
    for s_id ∈ eachindex(new_sites)
        site_name = new_sites[s_id]
        x_params = up_params_now(; site=site_name)
        scaled_params = getParamsAct(x_params, tblParams)
        site_location = name_to_id(site_name, sites_f)
        loc_land_init_now = land_init_space[site_location[1][2]]

        loc_forcing_now, loc_output, loc_obs_now = getLocDataObsN(out_data, forc, obs_now, site_location)

        tot_loss[s_id] = loc_loss(
            scaled_params,
            res_vec,
            out_vars,
            vars_cons,
            forward,
            tblParams,
            loc_obs_now,
            loc_forcing_now,
            loc_land_init_now,
            kwargs_fixed...
        )
    end
    return tot_loss
end