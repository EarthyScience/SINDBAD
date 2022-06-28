using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select

expFilejs = "exp_noW/settings_noW/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupExperiment(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);

out = createInitOut(info);

output = setupOutput(info);

@time outcubes = mapRunEcosystem(forcing, output, info.tem);

# outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
# @profview outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
ŷField = getfield(outsmodel, :fluxes) |> columntable
ŷ = hcat(getfield(ŷField, :gpp)...)' |> Matrix |> vec


observations = getObservation(info); 
info = setupOptimization(info);
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
