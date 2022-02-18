using Revise
using Sinbad
using Test
using GLMakie

m1 = rainSnow()
m2 = snowMelt()
m3 = evapSoil()
m4 = transpiration()
m5 = updateState()
models = (m1, m2, m3, m4, m5)
forcing, timesteps = getforcing()
outTable = evolveEcosystem(forcing, models, timesteps)

#vname=:wSoil
#vname=:wSoil
#plot(@eval outTable.$(vname))
plotResults(outTable)

function plotResults(outTable, startTime=1, endTime=365)
    fig = Figure(resolution = (2200, 900))
    axs = [Axis(fig[i,j]) for i in 1:3 for j in 1:6]
    for (i, vname) in enumerate(propertynames(outTable))
        lines!(axs[i], @eval outTable.$(vname))
        axs[i].title=string(vname)
        xlims!(axs[i], startTime, endTime)
    end
    fig
end
# for vname in propertynames(outTable)
#     plot(@eval outTable.$(vname))
# end