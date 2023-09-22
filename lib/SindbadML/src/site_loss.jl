export getSiteLossTEM
export siteLossInner

"""
    getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method)
- tem = (;
    )
"""
function getSiteLossTEM(models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method)
    println(@__LINE__," ",@__FILE__)
    coreTEM!(
        models,
        loc_forcing,
        loc_spinup_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem...)
    println(@__LINE__," ",@__FILE__)
    lossVec = getLossVector(loc_obs, loc_output, cost_options)
    println(@__LINE__," ",@__FILE__)
    t_loss = combineLoss(lossVec, constraint_method)
    println(@__LINE__," ",@__FILE__)
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

    println(@__LINE__," ",@__FILE__)
    out_data = get_tmp.(loc_output, (new_params,))
    #@code_warntype updateModelParametersType(param_to_index, models, new_params)
    new_models = updateModelParametersType(param_to_index, models, new_params)
    #@code_war ntype getSiteLossTEM(new_models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, out_data, land_init, tem, loc_obs, cost_options, constraint_method)
    println(@__LINE__," ",@__FILE__)
    return getSiteLossTEM(new_models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, out_data, land_init, tem, loc_obs, cost_options, constraint_method)
end

