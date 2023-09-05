export getSiteLossTEM
export siteLossInner

"""
    getSiteLossTEM(inits, data, data_optim, tem, optim)

- inits = (;
    selected_models,
    land_init
    );
- data = (;
    loc_forcing,
    forcing_one_timestep,
    allocated_output = loc_output
    );
- data_optim = (;
    site_obs = loc_obs,
    )
- tem = (;
    )
- optim = (;
    cost_options,
    multiconstraint_method
    );
"""
function getSiteLossTEM(inits, data, data_optim, tem, optim)
    #@code_warntype coreTEM!(inits..., data..., tem...)
    coreTEM!(inits..., data..., tem...)
    @code_warntype getLossVector(data_optim.site_obs, data.allocated_output, optim.cost_options)
    lossVec = getLossVector(data_optim.site_obs, data.allocated_output, optim.cost_options)
    t_loss = combineLoss(lossVec, optim.multiconstraint_method)
    return t_loss
end

"""
    siteLossInner(new_params, inits, data_cache, data_optim, tem, tbl_params)

- new_params: Array
- inits = (;
    selected_models,
    land_init
    );
- data = (;
    loc_forcing,
    forcing_one_timestep,
    allocated_output = DiffCache.(loc_output)
    );
- data_optim = (;
    site_obs = loc_obs,
    )
- tem = (;
    )
- optim = (;
    cost_options,
    multiconstraint_method
    );
- tbl_params = (;
    )
- optim = (;
    )

"""
function siteLossInner(new_params, inits, data_cache, data_optim, tem, param_to_index, optim)
    out_data = get_tmp.(data_cache.allocated_output, (new_params,))
    new_apps = updateModelParametersType(param_to_index, inits.selected_models, new_params)
    inits = (; selected_models = new_apps, land_init = inits.land_init)
    data = (; data_cache..., allocated_output = out_data)
    return getSiteLossTEM(inits, data, data_optim, tem, optim)
end

