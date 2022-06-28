using Revise
using Sindbad
using ProgressMeter
Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFilejs = "exp_mapEco/settings_mapEco/experiment.json"

local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs);
info = getConfiguration(expFile, local_root);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
# spinup_forcing = getSpinupForcing(forcing, info.tem);

output = setupOutput(info);

Sindbad.eval(:(debugcatch = []))
Sindbad.eval(:(debugcatcherr = []))


@time outcubes = mapRunEcosystem(forcing, output, info.tem);

outcubes[2]
