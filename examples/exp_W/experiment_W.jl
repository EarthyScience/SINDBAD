using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select
using Plots

experiment_json = "exp_W/settings_W/experiment.json"


info = getConfiguration(experiment_json);

info = setupExperiment(info);


forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

#Sindbad.eval(:(debugcatcherr = []))

outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);

# # optimization
# observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend))); 

# res = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
#     ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)

soilW=hcat(pools.soilW...)';
plot(soilW[:, 1])
plot!(soilW[:, 2])
plot!(soilW[:, 3])
plot!(soilW[:, 4])

groundW=hcat(pools.groundW...)';
plot(groundW[:, 1])


observations = getObservation(info); 
out = createInitOut(info);
optimizeit=true
outparams, outsmodel = optimizeModel(forcing, out, observations,info.tem, info.optim; spinup_forcing=spinup_forcing);  


obsV = :transpiration
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

modelVarInfo = [:fluxes, :transpiration]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
loss(y, yσ, ŷ, Val(:nse))

plot(ŷ)
plot!(y)

obsV = :evapotranspiration
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

modelVarInfo = [:fluxes, :evapotranspiration]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
loss(y, yσ, ŷ, Val(:nse))

plot(ŷ)
plot!(y)
