using Revise
using Sindbad
using ProgressMeter

expFilejs = "exp_mapEco/settings_mapEco/experiment.json"

local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs);
info = getConfiguration(expFile, local_root);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
spinup_forcing = getSpinupForcing(forcing, info);

output = setupOutput(info);

Sindbad.eval(:(debugcatch = []))
Sindbad.eval(:(debugcatcherr = []))

out = createInitOut(info);

@time outcubes = mapRunEcosystem(forcing, spinup_forcing, output, info.tem);

outcubes[2]
