using Revise
using Sinbad

# get experiment info
expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = runGetConfiguration(expFile);

## setupTEM => get the selected model structure, check consistency, etc...
# setupTEM!(info)


## prepare TEM => read forcing, create arrays if needed, handle observations when needed for optimization or calculation of model cost
varnames = propertynames(info.forcing.variables)
# varnames = [Symbol(_v) for _v in propertynames(info.forcing.variables)]
data_dict = Dict()
for v in varnames
    vinfo = getproperty(info.forcing.variables, v)
    if doOnePath === false
        dataPath = v.dataPath
    end
    ds = NCDatasets.Dataset(dataPath)
    srcVar = vinfo.sourceVariableName
    tarVar = Symbol(v)
    data_dict[tarVar]=ds[srcVar][1, 1, :]
end
## run TEM => optimization or forward run

## collect data and post process

# using GLMakie
# function plotResults(outTable, startTime=1, endTime=365)
#     fig = Figure(resolution = (2200, 900))
#     axs = [Axis(fig[i,j]) for i in 1:3 for j in 1:6]
#     for (i, vname) in enumerate(propertynames(outTable))
#         lines!(axs[i], @eval outTable.$(vname))
#         axs[i].title=string(vname)
#         xlims!(axs[i], startTime, endTime)
#     end
#     fig
# end

# plotResults(outTable)
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
