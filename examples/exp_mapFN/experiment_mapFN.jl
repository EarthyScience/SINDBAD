using Revise
using Distributed
# addprocs(Sys.CPU_THREADS - 20)
# @everywhere using Sindbad
using Sindbad
using ProgressMeter
# using ProfileView
# using BenchmarkTools

expFile = "exp_mapFN/settings_mapFN/experiment.json"

info = getConfiguration(expFile);
info = setupExperiment(info);
#observations = getObservation(info); # target observation!!
forcing = getForcing(info, Val(:yaxarray));
output = setupOutput(info);
# spinup_forcing = getSpinupForcing(forcing, info.tem);

@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);

outcubes[2]

Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NamedTuple with ")

(typeof((a=3,b=4)))