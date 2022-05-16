using Revise
using Sinbad
# using ProfileView
using BenchmarkTools

expFilejs = "sandbox/test_json/settings_minimal/experiment.json"
local_root ="/Users/lalonso/.julia/dev/Sinbad/"
expFile = local_root*expFilejs
info_exp = getExperimentConfiguration(expFile)
readConfiguration(info_exp, local_root)

info = getConfiguration(expFile, local_root)

info = setupModel!(info); # fails do to wCycle
out = createInitOut(info);
forcing = getForcing(info);
obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!
# plot(observations.transpiration)
# plot(observations.transpiration_σ)
optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);

outevolution = runEcosystem(approaches, forcing, out, modelvars, info.tem; nspins=3)
(y, ŷ) = getSimulationData(outevolution, observations, optimvars, obsvars)

#idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
#mean(abs2.(y[idxs] .- ŷ[idxs]))
#cor(y[idxs], ŷ[idxs])

outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=50, lossym=(:mse, :pcor));

fluxes = outdata.fluxes |> columntable;
pools = outdata.pools |> columntable;
soilW = hcat(pools.soilW...)';

using Plots
plot(fluxes.evapotranspiration)
plot(soilW)