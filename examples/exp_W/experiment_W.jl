using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select
using Plots

expFile = "exp_W/settings_W/experiment.json"


info = getConfiguration(expFile);

info = setupExperiment(info);


forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
spinup_forcing = getSpinupForcing(forcing, info.tem);

out = createInitOut(info);
outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
# @profview outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
pools = outsmodel.pools |> columntable;
soilW=hcat(pools.soilW...)';
plot(soilW[:, 1])
plot!(soilW[:, 2])
plot!(soilW[:, 3])
plot!(soilW[:, 4])

groundW=hcat(pools.groundW...)';
plot(groundW[:, 1])


observations = getObservation(info); 
info = setupOptimization(info);
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
