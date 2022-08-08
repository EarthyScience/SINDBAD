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

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
# optimization
observations = getObservation(info, Val(:yaxarray)); 

opt_params = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
    ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)

Sindbad.savecube(opt_params,"./optiparams.zarr")