using Revise
using Sindbad
using ProgressMeter
noStackTrace()

tbl = getSindbadModels()

experiment_json = "exp_mapEco/settings_mapEco/experiment.json";

info = getConfiguration(experiment_json);

info = setupExperiment(info);

info, forcing = getForcing(info);

# spinup_forcing = getSpinupForcing(forcing.data, info.tem);
output = setupOutput(info);

outcubes = mapRunEcosystem(forcing,
    output,
    info.tem,
    info.tem.models.forward;
    max_cache=info.model_run.rules.yax_max_cache);

# optimization
observations = getObservation(info, Val(:netcdf));

opt_params = mapOptimizeModel(forcing,
    output,
    info.tem,
    info.optim,
    observations,
    ;
    spinup_forcing=nothing,
    max_cache=info.model_run.rules.yax_max_cache)
