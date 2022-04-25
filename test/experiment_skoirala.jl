using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie

expFile = "sandbox/test_json/settings_minimal/experiment.json"

info = getConfiguration(expFile);
info = setupModel!(info);
out = getInitOut(info);

forcing = getForcing(info);


obsvars, modelvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
# tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);

# initPools = getInitPools(info)
# @show out.pools.soilW

outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);

typeof(outsp[1].pools.soilW)
outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);

# outfor = runEcosystem(approaches, forcing, out, info.tem.helpers);
pprint(outsp)


@time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);

for it in 1:10
    @time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=3)
end
outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams, obsvars, modelvars, info.tem, info.opti; maxfevals=1);

outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams, obsvars, modelvars, info.tem, info.opti; maxfevals=30);
# outf=columntable(outdata.fluxes)
using GLMakie
fig = Figure(resolution=(2200, 900))
lines(outdata.transpiration)
lines!(outdata.evapotranspiration)
lines!(observations.evapotranspiration)
