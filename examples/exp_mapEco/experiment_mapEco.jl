using Revise
using Sindbad
using ProgressMeter
# Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFile = "exp_mapEco/settings_mapEco/experiment.json";


info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));

# spinup_forcing = getSpinupForcing(forcing.data, info.tem);
output = setupOutput(info);

#Sindbad.eval(:(debugcatcherr = []))

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);
# optimization
observations = getObservation(info, Val(:yaxarray)); 

res = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
    ; spinup_forcing=nothing,max_cache=2e9)

savecube(res,"./optiparams.zarr")