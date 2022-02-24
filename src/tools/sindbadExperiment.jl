using Revise
using Sinbad
# get experiment info
expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = runGetConfiguration(expFile);

## setupTEM => get the selected model structure, check consistency, etc...

info = setupTEM(info)


## prepare TEM => read forcing, create arrays if needed, handle observations when needed for optimization or calculation of model cost
forcing = getForcing(info)

## run TEM => optimization or forward run
timesteps = size(forcing)[1]
m1 = rainSnow()
m2 = snowMelt()
m3 = evapSoil()
m4 = transpiration()
m5 = updateState()
models = (m1, m2, m3, m4, m5)
outTable = evolveEcosystem(forcing, models, timesteps)

# models = info.tem.models

# outTable = evolveEcosystem(forcing, models, timesteps) # evolve is intransitive, may be use update?


<<<<<<< HEAD
# function runExperiment(exp_file, )
# end

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

endTime=3000
plotResults(outTable; startTime=1,endTime=endTime)
"""
# selModels = propertynames(info.modelStructure.modules)
# corePath = joinpath(pwd(), info.modelStructure.paths.coreTEM)
# (; info.modelStructure.paths.coreTEM = corePath)

# splitArray = split("info.tem.models", ".")

# for fn in split("info.tem.models", ".")
#     if fn !== last(splitArray)
#         if fn ∉ info. 
#         fnn=:fn
#         merge(info, [fnn => 1])
#     end
# end

# runmodel

# post process
"""
=======
outTable = evolveEcosystem(forcing, selected_models, timesteps) # evolve is intransitive, may be use update?

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

endTime=3000
plotResults(outTable; startTime=1,endTime=endTime)
>>>>>>> 726b9fd (merge of main and tools_skoirala; cleanup, unit conversion)
