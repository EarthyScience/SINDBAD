using Revise
using Sindbad
using ProgressMeter
toggleStackTraceNT()

# tbl = getSindbadModels()

experiment_json = "../exp_mapEco/settings_mapEco/experiment.json";

info = getConfiguration(experiment_json);

info = setupExperiment(info);

forcing = getForcing(info);

output = setupOutput(info, forcing.helpers);

outcubes = runTEMYAX(forcing,
    output,
    info.tem,
    info.tem.models.forward;
    max_cache=info.experiment.exe_rules.yax_max_cache);

# optimization
observations = getObservation(info, forcing.helpers);

opt_params = optimizeTEMYax(forcing,
    output,
    info.tem,
    info.optim,
    observations,
    max_cache=info.experiment.exe_rules.yax_max_cache)
