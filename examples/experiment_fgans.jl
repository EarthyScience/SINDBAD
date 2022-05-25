using Revise
using Sinbad
using ProgressMeter
# using ProfileView
# using BenchmarkTools

expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = @__DIR__
expFile = joinpath(local_root, expFilejs)

info = getConfiguration(expFile, local_root);
info = setupModel!(info);
#observations = getObservation(info); # target observation!!
forcing = getForcing(info, Val(:yaxarray))
output = setupOutput(info)

mapRunEcosystem(forcing, output, info.tem)