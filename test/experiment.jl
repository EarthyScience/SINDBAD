using Revise
using Sinbad
using ProfileView
#using GLMakie

expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = getConfiguration(expFile);
info = setupModel!(info);
forcing = getForcing(info)
observationO = getObservation(info) # target observation!!
optimParams = info.opti.params2opti
approaches = info.tem.models.forward

initStates = (; wSoil=[0.01], wSnow=[0.01])

wsnowvals = info.modelStructure.states.w.pools.wSnow
wsoilvals = info.modelStructure.states.w.pools.wSoil

wSoil = fill(wsoilvals[end], (wsoilvals[1], wsoilvals[2]))
wSnow = fill(wsnowvals[end], (wsnowvals[1], wsnowvals[2]))

initStates = (; wSoil, wSnow)
obsnames, modelnames = getConstraintNames(info)
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti)

#tableParams, outEcosystem = optimizeModel(forcing, observationO, approaches, optimParams, initStates, obsnames, modelnames)

@ProfileView.profview optimizeModel(forcing, observationO, approaches, optimParams, initStates, obsnames, modelnames)