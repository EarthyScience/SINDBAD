using Revise
using Sindbad

noStackTrace()
#experiment_json = "exp_WROASTED/settings_WROASTED/experiment.json"
experiment_json = "examples/exp_WROASTED/settings_WROASTED/experiment.json"

run_output = runExperiment(experiment_json);


doitstepwise = false
if doitstepwise
    info = getConfiguration(experiment_json);
    info = setupExperiment(info);
    forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
    # spinup_forcing = getSpinupForcing(forcing, info.tem);
    output = setupOutput(info);

    # forward run
    outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);

    # optimization
    observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend))); 
    res = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
        ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
end