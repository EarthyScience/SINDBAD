using Revise
using Sindbad
using ProgressMeter
# using ProfileView
# using BenchmarkTools

expFilejs = "exp_mapFN/settings_mapFN/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/Sindbad.jl/"
local_root = dirname(Base.active_project())
# local_root = @__DIR__
expFile = joinpath(local_root, expFilejs);

info = getConfiguration(expFile, local_root);
info = setupModel!(info);
#observations = getObservation(info); # target observation!!
forcing = getForcing(info, Val(:yaxarray));
output = setupOutput(info);

@time outcubes = mapRunEcosystem(forcing, output, info.tem);

outcubes[2]