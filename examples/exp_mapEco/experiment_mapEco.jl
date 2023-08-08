using Revise
using Sindbad
using ProgressMeter
noStackTrace()

# tbl = getSindbadModels()

experiment_json = "../exp_mapEco/settings_mapEco/experiment.json";

info = getConfiguration(experiment_json);

info = setupExperiment(info);

forcing = getForcing(info);

output = setupOutput(info, forcing.helpers);

outcubes = mapRunEcosystem(forcing,
    output,
    info.tem,
    info.tem.models.forward;
    max_cache=info.experiment.exe_rules.yax_max_cache);

# optimization
observations = getObservation(info, forcing.helpers);

opt_params = mapOptimizeModel(forcing,
    output,
    info.tem,
    info.optim,
    observations,
    max_cache=info.experiment.exe_rules.yax_max_cache)
