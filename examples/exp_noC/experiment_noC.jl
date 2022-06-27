using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select


expFilejs = "exp_noC/settings_noC/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));
spinup_forcing = getSpinupForcing(forcing, info);

out = createInitOut(info);
outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);
@time outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem, spinup_forcing=spinup_forcing);




observations = getObservation(info); 
info = setupOptimization(info);


tblParams = getParameters(info.tem.models.forward, info.optim.optimized_paramaters)

# get the defaults and bounds
default_values = tblParams.defaults
lower_bounds = tblParams.lower
upper_bounds = tblParams.upper


out = createInitOut(info);
outparams, outsmodel = optimizeModel(forcing, out, observations,
info.tem, info.optim; spinup_forcing=spinup_forcing);    
obsV = :evapotranspiration
modelVarInfo = [:fluxes, :evapotranspiration]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

plot(ŷ)
plot!(y)
# plot!(yσ)

obsV = :gpp
modelVarInfo = [:fluxes, :gpp]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix |> vec;
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

using Plots
plot(ŷ)
plot!(y)
