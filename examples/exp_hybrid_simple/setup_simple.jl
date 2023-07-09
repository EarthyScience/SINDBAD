using Sindbad, ForwardSindbad, OptimizeSindbad
function setup_simple()
    #experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"

    experiment_json = "../exp_hybrid_simple/settings_hybrid/experiment.json"
    info = getExperimentInfo(experiment_json)
    info, forcing = getForcing(info, Val{:zarr}())
    land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models)
    output = setupOutput(info)
    forc = getKeyedArrayFromYaxArray(forcing)
    observations = getObservation(info, Val(Symbol(info.model_run.rules.data_backend)))
    obs = getKeyedArrayFromYaxArray(observations)

    tblParams = getParameters(info.tem.models.forward,
        info.optim.default_parameter,
        info.optim.optimized_parameters)

    loc_space_maps,
    loc_space_names,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one = prepRunEcosystem(Sindbad.get_tmp.(output.data, tblParams.default),
        output.land_init,
        info.tem.models.forward,
        forc,
        forcing.sizes,
        info.tem)

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