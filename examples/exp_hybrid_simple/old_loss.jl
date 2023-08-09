function get_loc_loss(
    new_apps,
    loc_obs,
    loc_forcing,
    loc_land_init, # now fixed arguments
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_optim,
    forcing_one_timestep)
    big_land = SindbadTEM.coreEcosystem(
        new_apps,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_land_init,
        forcing_one_timestep)
    loss_vector = getLossVector(loc_obs, landWrapper(big_land), tem_optim)
    #@show loss_vector
    t_loss = combineLoss(loss_vector, Val{:sum}())
    return t_loss
end

function loc_loss(up_params, forward, tbl_params, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    new_apps = Tuple(updateModelParametersType(tbl_params, forward, up_params))
    return get_loc_loss(new_apps, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
end

function fdiff_grads(f_loss, v, forward, tbl_params, loc_obs, loc_forcing, loc_land_init, kwargs_fixed)
    gf(v) = f_loss(v, forward, tbl_params, loc_obs, loc_forcing, loc_land_init, kwargs_fixed...)
    return ForwardDiff.gradient(gf, v)
end
