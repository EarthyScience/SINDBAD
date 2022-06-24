using Revise
using Distributed
# addprocs(Sys.CPU_THREADS - 20)
# @everywhere using Sindbad
using Sindbad
using ProgressMeter
# using ProfileView
# using BenchmarkTools

expFilejs = "exp_mapEco/settings_mapEco/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/Sindbad.jl/"
local_root = dirname(Base.active_project())
# local_root = @__DIR__
expFile = joinpath(local_root, expFilejs);
info = getConfiguration(expFile, local_root);
info = setupModel!(info);
#observations = getObservation(info); # target observation!!
forcing = getForcing(info, Val(:yaxarray));
output = setupOutput(info);


Sindbad.eval(:(debugcatch = []))
Sindbad.eval(:(debugcatcherr = []))
out = createInitOut(info);
forcing2 = (; Pair.(forcing.variables, forcing.dims)...)

outsmodel = runEcosystem(info.tem.models.forward, forcing2, out, info.tem; nspins=1);

@time outcubes = mapRunEcosystem(forcing, output, info.tem);

@time outcubes = mapRunEcosystem(forcing, output, info.tem);

outcubes[2]

Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NamedTuple with ")

(typeof((a=3,b=4)))