using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select

expFile = "exp_MLP/settings_MLP/experiment.json"

info = getConfiguration(expFile);

info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
spinup_forcing = getSpinupForcing(forcing, info);

out = createInitOut(info);
outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
# @profview outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);


observations = getObservation(info); 
out = createInitOut(info);
optimizeit=true
outparams, outsmodel = optimizeModel(forcing, out, observations,info.tem, info.optim; spinup_forcing=spinup_forcing);   
obsV = :gpp
modelVarInfo = [:fluxes, :gpp]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));
loss(y, yσ, ŷ, Val(:nse))

using Plots
plot(ŷ)
plot!(y)
