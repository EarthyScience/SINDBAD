using Revise
using Sindbad
using Tables:
    columntable,
    matrix
using TableOperations:
    select
using Plots

expFilejs = "exp_W/settings_W/experiment.json"
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);


forcing = getForcing(info, Val(Symbol(info.forcing.data_backend)));

out = createInitOut(info);
outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
# @profview outsmodel = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
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
outparams, outsmodel = optimizeModel(forcing, out, observations,info.tem, info.optim; nspins=1);  


obsV = :transpiration
y = observations |> select(obsV) |> matrix;
yσ = observations |> select(Symbol(string(obsV)*"_σ")) |> matrix;

modelVarInfo = [:fluxes, :transpiration]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix;
loss(y, yσ, ŷ, Val(:nse))

plot(ŷ)
plot!(y)

obsV = :evapotranspiration
y = observations |> select(obsV) |> matrix;
yσ = observations |> select(Symbol(string(obsV)*"_σ")) |> matrix;

modelVarInfo = [:fluxes, :evapotranspiration]
ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable;
ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)' |> Matrix;
loss(y, yσ, ŷ, Val(:nse))

plot(ŷ)
plot!(y)
