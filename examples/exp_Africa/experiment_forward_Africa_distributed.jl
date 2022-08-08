using Revise
using Distributed
addprocs(16)
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__,".."))

@everywhere using Sindbad

expFile = "exp_Africa/settings_Africa/experiment.json"

info = getConfiguration(expFile);

info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);


output = setupOutput(info);

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);

