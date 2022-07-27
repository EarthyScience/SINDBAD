using Revise
using Sindbad
# using Suppressor
# using Optimization
using Aqua
Aqua.test_all(Sindbad)
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")
expFile = "exp_WROASTED/settings_WROASTED/experiment.json"


info = getConfiguration(expFile);
info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);

output = setupOutput(info);

#Sindbad.eval(:(debugcatcherr = []))

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);

# optimization
observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend))); 

res = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
    ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
