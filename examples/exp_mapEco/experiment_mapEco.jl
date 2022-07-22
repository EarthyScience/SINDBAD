using Revise
using Sindbad
using ProgressMeter
# Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFile = "exp_mapEco/settings_mapEco/experiment.json"


info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
# spinup_forcing = getSpinupForcing(forcing.data, info.tem);



output = setupOutput(info);
Sindbad.eval(:(debugcatcherr = []))
@time outcubes = mapRunEcosystem(forcing, output, info.tem);
outcubes[2]

# optimization
info = setupOptimization(info);
observations = getObservation(info, Val(:yaxarray_s)); 


info_optim = info.optim;
tem = info.tem;
optimVars = info_optim.variables.optim;
# get the list of observed variables, model variables to compare observation against, 
# obsVars, optimVars, storeVars = getConstraintNames(info);

# get the subset of parameters table that consists of only optimized parameters
tblParams = getParameters(tem.models.forward)
tblParams = getParameters(tem.models.forward, info_optim.optimized_paramaters)

# get the defaults and bounds
default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)


tmp = observations.data[1]
outparams, outsmodel = optimizeModel(forcing, output, info.tem, info.optim, observations);  
