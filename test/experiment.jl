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

initStates = (; wSoil=[0.01], wSnow=[0.01])

wsnowvals = info.modelStructure.states.w.pools.wSnow


wsoilvals = info.modelStructure.states.w.pools.wSoil

wSoil = fill(wsoilvals[end], (wsoilvals[1], wsoilvals[2]))
wSnow = fill(wsnowvals[end], (wsnowvals[1], wsnowvals[2]))

initStates = (; wSoil, wSnow)
obsnames, modelnames = getConstraintNames(info)
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti)

#tableParams, outEcosystem = optimizeModel(forcing, observationO, approaches, optimParams, initStates, obsnames, modelnames)
outsp = runSpinup(approaches, initStates, forcing, info, false)
outparams, outdata = optimizeModel(forcing, info, observationO, approaches, optimParams, initStates, obsnames, modelnames)

outf=columntable(outdata.fluxes)
fig = Figure(resolution = (2200, 900))
    lines!(axs[1], outf.evapTotal)
fig

lines(outf.evapTotal)
lines!(outf.transpiration)
lines!(outf.evapSoil)


plotResults(outdata)
## collect data and post process
using GLMakie
function plotResults(outTable; startTime=1, endTime=365)
    fig = Figure(resolution = (2200, 900))
    axs = [Axis(fig[i,j]) for i in 1:3 for j in 1:6]
    for (i, vname) in enumerate(propertynames(outTable))
        lines!(axs[i], @eval outTable.$(vname))
        axs[i].title=string(vname)
        xlims!(axs[i], startTime, endTime)
    end
    fig
end

# @ProfileView.profview optimizeModel(forcing, observationO, approaches, optimParams, initStates, obsnames, modelnames)