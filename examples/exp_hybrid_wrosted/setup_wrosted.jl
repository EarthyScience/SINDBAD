using Sindbad, ForwardSindbad, OptimizeSindbad
function setup_simple()
    experiment_json = "../exp_hybrid_wrosted/settings_wrosted/experiment.json"
    info = getExperimentInfo(experiment_json)
    info, forcing = getForcing(info, Val{:zarr}())
    land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models)
    output = setupOutput(info)
    forc = getKeyedArrayFromYaxArray(forcing)
    observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)))
    obs = getKeyedArrayFromYaxArray(observations)

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
    forward = info.tem.models.forward

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
        obs)
end