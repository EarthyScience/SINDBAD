using SlurmClusterManager, Distributed
addprocs(SlurmManager())
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__, ".."))

@everywhere using Sindbad

experiment_json = "exp_Africa/settings_Africa/experiment.json"

info = getConfiguration(experiment_json);

info = setupExperiment(info);
info, forcing = getForcing(info);
# spinup_forcing = getSpinupForcing(forcing, info.tem);

output = setupOutput(info);

outcubes = mapRunEcosystem(forcing,
    output,
    info.tem,
    info.tem.models.forward;
    max_cache=info.model_run.rules.yax_max_cache);
