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
outparams, outdata = optimizeModel(forcing, info, observationO, approaches, optimParams, initStates, obsnames, modelnames; maxfevals=1);
outparams, outdata = optimizeModel(forcing, info, observationO, approaches, optimParams, initStates, obsnames, modelnames; maxfevals=30);

variables = info.modelRun.varsToSum

vars2sum = info.modelRun.varsToSum
NamedTuple{(Symbol("components"),)}(vars2sum)
tarr=propertynames(vars2sum)
outspt=Table(outsp[1])
outsp2=(;fluxes=(;b=2))
for tarname in tarr
    comps = Symbol.(getfield(vars2sum, tarname).components)
    outfield = Symbol.(getfield(vars2sum, tarname).outfield)
    datasubfields = getfield(outsp[1], outfield)
    dat = sum([getfield(datasubfields, compname) for compname in comps if compname in propertynames(datasubfields)])
    @eval $tarname = $dat
    outsp2 = @eval (; outsp2..., $outfield = (; outsp2.$outfield..., $tarname))
    @show tarname, dat, outfield
end

b=vars2sum[(tarr)]
# tarr. [(:evapTotal,)]
A = (a = 1, b = 2, c = 3)

NamedTuple{(:a,:b)}(A)


variables |> select(tarr[1])


for varib in keys(info.modelRun.varsToSum)
    @eval tmp=info.modelRun.varsToSum.$varib
    @show tmp.components
end

for varib in keys(info.modelRun.varsToSum)
    @eval tmp=info.modelRun.varsToSum.$varib
    tarfield = Symbol(tmp.destination)
    tmpSum = 0.0
    for comp in tmp.components
        fieldname=Symbol(split(comp, ".")[1])
        compname=Symbol(split(comp, ".")[2])
        ofields = propertynames(@eval outsp[1].$fieldname)
        if compname in ofields
            @eval tmpComp = outsp[1].$fieldname.$compname
            # if fieldname == Symbol("states")
            #     tmpComp = sum(tmpComp)
            # end
            tmpSum = tmpSum + tmpComp
            @show compname, tmpComp, tmpSum
            # @show @eval $compname
        end
        # @show fieldname, compname, ofields
    end
    @show tmpSum, varib
    @eval $varib = $tmpSum
    @show evapTotal
    # (; outsp[1].fluxes..., evapTotal)
    # outsp = (; outsp..., fluxes = (; outsp.fluxes..., evapTotal))
    # @eval outsp = (; outsp..., ($tarfield = (; outsp[1].$tarfield..., $varib)))
end
# out = (; out..., fluxes = (; out.fluxes..., transpiration, PETveg))

# ŷ = outdata.fluxes |> select(Symbol("rain")) |> columntable |> matrix
outf=columntable(outdata.fluxes)
fig = Figure(resolution = (2200, 900))
lines(outf.transpiration)
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