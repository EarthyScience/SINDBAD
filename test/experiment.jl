using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie

expFile = "sandbox/test_json/settings_minimal/experiment.json"

info = getConfiguration(expFile);
info = setupModel!(info);

forcing = getForcing(info);

obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;

obsvars

# initPools = getInitPools(info)
out = getInitOut(info);
outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
@time outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);
#newApproaches = updateParameters(tblParams, approaches)
@time outevolution = runEcosystem(approaches, forcing, outsp[1], modelvars, info.tem; nspins=3)

# outfor = runEcosystem(approaches, forcing, out, info.tem.helpers);
#pprint(outsp)

outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=1);

poolss = outforw.pools |> columntable
poolsMatrix = hcat(poolss.soilW...)'

using GR
plot(poolsMatrix[1:365,1])
oplot(poolsMatrix[1:365, 2])
oplot(poolsMatrix[1:365, 3])
oplot(poolsMatrix[1:365, 4])


# outf=columntable(outdata.fluxes)
#=
using GLMakies
fig = Figure(resolution=(2200, 900))
lines(outdata.transpiration)
lines!(outdata.evapotranspiration)
lines!(observations.evapotranspiration)

=#
