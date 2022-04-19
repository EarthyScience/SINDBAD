using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie

expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = getConfiguration(expFile);
info = setupModel!(info);

# forcing = getForcing(info);


obsvars, modelvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);
# info = (; info..., opti = (;));
# info = (;info..., tem = (;));

initPools = getInitPools(info)

outsp = runSpinup(approaches, initPools, forcing, info.tem, false; nspins=1);
# frame = stacktrace()[1]
# frame.file
# frame.line
pprint(outsp)
outparams, outdata = optimizeModel(forcing, observations, approaches, optimParams, initPools, obsvars, modelvars, info.tem, info.opti; maxfevals=1);

outparams, outdata = optimizeModel(forcing, observations, approaches, optimParams, initPools, obsvars, modelvars, info.tem, info.opti; maxfevals=30);
# outf=columntable(outdata.fluxes)
using GLMakie
fig = Figure(resolution = (2200, 900))
lines(outdata.transpiration)
lines!(outdata.evapotranspiration)
lines!(observations.evapotranspiration)
