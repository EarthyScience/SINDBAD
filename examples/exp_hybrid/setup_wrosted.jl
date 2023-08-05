using Sindbad, ForwardSindbad, OptimizeSindbad

function setup_wrosted()
    # settings 
    experiment_json = "../exp_hybrid/settings_gradWroasted/experiment.json"
    info = getExperimentInfo(experiment_json)#; replace_info=replace_info); # note that this will modify information from json with the replace_info
    forcing = getForcing(info)
    # Sindbad.eval(:(error_catcher = []));
    land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models)
    output = setupOutput(info)
    forc = getKeyedArrayWithNames(forcing)
    observations = getObservation(info, forcing.helpers)
    obs = getKeyedArrayWithNames(observations)

    loc_space_maps,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one = prepRunEcosystem(output.data,
        output.land_init,
        info.tem.models.forward,
        forc,
        forcing.sizes,
        info.tem)

    tblParams = getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)

    tem_helpers = info.tem.helpers
    tem_spinup = info.tem.spinup
    tem_models = info.tem.models
    tem_variables = info.tem.variables
    tem_optim = info.optim
    out_variables = output.variables
    forward = info.tem.models.forward # forward

    return (; loc_space_maps,
        loc_space_names,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one,
        tblParams,
        forward,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_variables,
        tem_optim,
        out_variables,
        output,
        forc,
        obs
    )
end