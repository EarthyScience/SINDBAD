using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select

experiment_json = "exp_noW/settings_noW/experiment.json"


info = getConfiguration(experiment_json);
outcubes = runExperiment(experiment_json);

info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);

land_init = createLandInit(info);

output = setupOutput(info);

@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);

# outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
# @profview outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
ŷField = getfield(outsmodel, :fluxes) |> columntable
ŷ = hcat(getfield(ŷField, :gpp)...)' |> Matrix |> vec


observations = getObservation(info); 
land_init = createLandInit(info);
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
