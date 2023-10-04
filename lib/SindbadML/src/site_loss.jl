export getSiteLossTEM
export siteLossInner

"""
    getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method)
- tem = (;
    )
"""
function getSiteLossTEM(forward_models, spinup_models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method; show_vec=false)
    coreTEM!(
        forward_models,
        spinup_models,
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
    getSiteLossTEM(models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method)
- tem = (;
    )
"""
function getSiteLossTEM(models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method; show_vec=false)
    #println(@__LINE__," ",@__FILE__)
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
    if show_vec
        println("   loss_vector: ", Tuple([Pair.(string.(cost_options.variable), lossVec)...]) )
    end
    return t_loss
end


"""
    siteLossInner(new_params, models, loc_forcing, forcing_one_timestep, loc_output, land_init, tem, param_to_index, loc_obs, cost_options, constraint_method)
    
- tem = (;
    )
"""
function getTmpOut(loc_output, _, ::UseFiniteDiff)
    return loc_output
end

function getTmpOut(loc_output, _, ::UseFiniteDifferences)
    return loc_output
end

function getTmpOut(loc_output, new_params, ::UseForwardDiff)
    return get_tmp.(loc_output, (new_params,))
end

function siteLossInner(
    new_params,
    gradient_lib,
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
    constraint_method;
    show_vec=false)

    out_data = getTmpOut(loc_output, new_params, gradient_lib)
    new_models = updateModelParametersType(param_to_index, models, new_params)
    return getSiteLossTEM(new_models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, out_data, land_init, tem, loc_obs, cost_options, constraint_method; show_vec=show_vec)
end

