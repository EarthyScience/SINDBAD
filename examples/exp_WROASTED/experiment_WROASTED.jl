using Revise
using Sindbad
# using Suppressor
# using Optimization
using Tables:
    columntable,
    matrix
using TableOperations:
    select
expFilejs = "exp_WROASTED/settings_WROASTED/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);
info = setupModel!(info);
forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));

observations = getObservation(info); 
info = setupOptimization(info);
out = createInitOut(info);
outparams, outdata = optimizeModel(forcing, out, observations,
info.tem, info.optim; nspins=1);    

outdata = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
outsmodel=outdata;
obsV = :gpp
modelVarInfo = [:fluxes, :gpp]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix;
y = getproperty(observations, obsV);
yσ = getproperty(observations, Symbol(string(obsV)*"_σ"));

using Plots
plot(ŷ)
plot!(y)
plot!(yσ)

states = outdata.states |> columntable;
pools = outdata.pools |> columntable;
fluxes = outdata.fluxes |> columntable;

using Plots
plot(fluxes.NEE)
plot!(observations.nee)