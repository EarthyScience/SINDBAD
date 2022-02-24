using Revise
using Sinbad
using Sinbad.Models
# get experiment info
expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = runGetConfiguration(expFile);

## setupTEM => get the selected model structure, check consistency, etc...

info = setupTEM(info)


## prepare TEM => read forcing, create arrays if needed, handle observations when needed for optimization or calculation of model cost
forcing = getForcing(info)

## run TEM => optimization or forward run
timesteps = size(forcing)[1]
selected_models = [getStates_simple(), rainSnow_Tair(), snowMelt_snowFrac(), evapSoil_demSup(), transpiration_demSup(), updateState_wSimple()]


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