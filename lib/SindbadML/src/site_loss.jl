export getSiteLossTEM
export siteLossInner

"""
    getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method)
- tem = (;
    )
"""
function getSiteLossTEM(models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method)

    coreTEM!(
        models,
        loc_forcing,
        loc_spinup_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem...)

    lossVec = getLossVector(loc_obs, loc_output, cost_options)
    t_loss = combineLoss(lossVec, constraint_method)
    return t_loss
end


"""
    siteLossInner(new_params, models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem, param_to_index, loc_obs, cost_options, constraint_method)
    
- tem = (;
    )
"""
function siteLossInner(
    new_params,
    models,
    loc_forcing,
    loc_spinup_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem,
    param_to_index,
    loc_obs,
    cost_options,
    constraint_method)

    out_data = get_tmp.(loc_output, (new_params,))
    new_models = updateModelParametersType(param_to_index, models, new_params)
 
    return getSiteLossTEM(new_models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, out_data, land_init, tem, loc_obs, cost_options, constraint_method)
end

