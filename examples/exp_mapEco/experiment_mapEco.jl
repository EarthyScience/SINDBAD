using Revise
using Sindbad
using ProgressMeter
Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFile = "exp_mapEco/settings_mapEco/experiment.json"


info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
# spinup_forcing = getSpinupForcing(forcing.data, info.tem);



output = setupOutput(info);

@time outcubes = mapRunEcosystem(forcing, output, info.tem);
outcubes[2]

# optimization
info = setupOptimization(info);
observations = getObservation(info, Val(:yaxarray)); 
tmp = observations.data[1]
outparams, outsmodel = optimizeModel(forcing, output, info.tem, info.optim, observations);  
