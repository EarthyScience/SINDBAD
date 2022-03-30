using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie


expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = getConfiguration(expFile);
info = setupModel!(info);
forcing = getForcing(info)
observationO = getObservation(info) # target observation!!
optimParams = info.opti.params2opti
approaches = info.tem.models.forward

initStates = getInitStates(info)

obsnames, modelnames = getConstraintNames(info)
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti)

outsp = runSpinup(approaches, initStates, forcing, info.tem, false)
# out = runEcosystem(approaches, initStates, forcing, info.tem, false)

outparams, outdata = optimizeModel(forcing, observationO, approaches, optimParams, initStates, obsnames, modelnames, info.tem, info.opti; maxfevals=1);
outparams, outdata = optimizeModel(forcing, observationO, approaches, optimParams, initStates, obsnames, modelnames, info.tem, info.opti; maxfevals=300);
outf=columntable(outdata.fluxes)
fig = Figure(resolution = (2200, 900))
lines(outf.transpiration)
lines!(outf.evapSoil)
