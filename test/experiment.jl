using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie


expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = getConfiguration(expFile);
info = setupModel!(info);
forcing = getForcing(info)
observations = getObservation(info) # target observation!!
optimParams = info.opti.params2opti
approaches = info.tem.models.forward

initPools = getInitPools(info)

obsnames, modelnames = getConstraintNames(info)
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti)

outsp = runSpinup(approaches, initPools, forcing, info.tem, false)
# out = runEcosystem(approaches, initPools, forcing, info.tem, false)

outparams, outdata = optimizeModel(forcing, observations, approaches, optimParams, initPools, obsnames, modelnames, info.tem, info.opti; maxfevals=1);
outparams, outdata = optimizeModel(forcing, observations, approaches, optimParams, initPools, obsnames, modelnames, info.tem, info.opti; maxfevals=300);
outf=columntable(outdata.fluxes)
fig = Figure(resolution = (2200, 900))
lines(outf.transpiration)
lines!(outf.evapSoil)
