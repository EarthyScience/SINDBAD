using Revise
using Distributed
# addprocs(Sys.CPU_THREADS - 20)
# @everywhere using Sindbad
using Sindbad
using ProgressMeter
# using ProfileView
# using BenchmarkTools

experiment_json = "exp_mapFN/settings_mapFN/experiment.json"

info = getConfiguration(experiment_json);
info = setupExperiment(info);
#observations = getObservation(info); # target observation!!
forcing = getForcing(info, Val(:yaxarray));
output = setupOutput(info, forcing.sizes);
# spinup_forcing = getSpinupForcing(forcing, info.tem);

@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);

outcubes[2]

Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NamedTuple with ")

(typeof((a=3,b=4)))