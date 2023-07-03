function get_loc_loss(
    new_apps,
    loc_obs,
    loc_forcing,
    loc_land_init, # now fixed arguments
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    f_one)
    big_land = ForwardSindbad.coreEcosystem(
        new_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        f_one)
    lossVec = getLossVectorArray(loc_obs, landWrapper(big_land), tem_optim)
    t_loss = combineLossArray(lossVec, Val{:sum}())
    return t_loss
end

function loc_loss(up_params, forward, tblParams, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    new_apps = Tuple(updateModelParametersType(tblParams, forward, up_params))
    return get_loc_loss(new_apps, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
end

function fdiff_grads(f_loss, v, forward, tblParams, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)
    gf(v) = f_loss(v, forward, tblParams, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    return ForwardDiff.gradient(gf, v)
end
