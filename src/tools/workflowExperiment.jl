using Revise
using Sinbad
using Test


m0 = getStates()
m1 = rainSnow()
m2 = snowMelt()
m3 = evapSoil()
m4 = transpiration()
m5 = updateState()
models = (m0, m1, m2, m3, m4, m5)
forcing, timesteps = getforcing(filename="data/BE-Vie.2000-2019.nc")
outTable = evolveEcosystem(forcing, models, timesteps)



using GLMakie
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

plotResults(outTable)
