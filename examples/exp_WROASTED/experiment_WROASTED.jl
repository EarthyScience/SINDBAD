using Revise
using Sindbad
# using Suppressor
# using Optimization
using Tables:
    columntable,
    matrix
using TableOperations:
    select
expFile = "exp_WROASTED/settings_WROASTED/experiment.json"


info = getConfiguration(expFile);
info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
spinup_forcing = getSpinupForcing(forcing, info.tem);

observations = getObservation(info); 
out = createInitOut(info);

outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
obsV = :gpp;
modelVarInfo = [:fluxes, :gpp];
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

using Plots
plot(ŷ)
plot!(y)
plot!(yσ)

states = outsmodel.states |> columntable;
pools = outsmodel.pools |> columntable;
fluxes = outsmodel.fluxes |> columntable;

using Plots
plot(fluxes.NEE)
plot!(observations.nee)