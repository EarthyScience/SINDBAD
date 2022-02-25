using Revise
using Sinbad
include("setupTEM.jl")

expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = runGetConfiguration(expFile);

## setupTEM => get the selected model structure, check consistency, etc...
info = setupTEM!(info);

## prepare TEM => read forcing, create arrays if needed, handle observations when needed for optimization or calculation of model cost
forcing = getForcing(info)

## run TEM => optimization or forward run
for t = 1:50
    # @show t
    @time outTable = runTEM(info, forcing)
end
## post process
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

