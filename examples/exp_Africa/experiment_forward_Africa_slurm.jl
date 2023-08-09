using SlurmClusterManager, Distributed
addprocs(SlurmManager())
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__, ".."))

@everywhere using Sindbad

experiment_json = "exp_Africa/settings_Africa/experiment.json"

info = getConfiguration(experiment_json);

info = setupExperiment(info);
forcing = getForcing(info);

outcubes = runTEMYAX(forcing,
    output,
    info.tem,
    info.tem.models.forward;
    max_cache=info.experiment.exe_rules.yax_max_cache);
