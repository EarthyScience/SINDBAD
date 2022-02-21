function runCoreTEM(info, models, out, update_timeseries=true)
    # m0 = getStates()
    # m1 = rainSnow()
    # m2 = snowMelt()
    # m3 = evapSoil()
    # m4 = transpiration()
    # m5 = updateState()
    # models = (m0, m1, m2, m3, m4, m5)
    outTable = evolveEcosystem(forcing, models, timesteps) # evolve is intransitive, may be use update?
    if update_timeseries
        # update the fluxes and states.. usually for spinup, we do not need the time series, and so this flag is useful for spinup vs forward run.. may be this chunk needs to be another function because it needs to have option to have the time series of the variables that are listed to be stored in output.json.
        println("not done yet")
    end
    return outTable
end

function runSpinupTEM(info, forcing)
    # runCoreTEM(info, models, out, update_timeseries=false)
    ### handle spinup things here
    ### runs
end

function runTEM(info, forcing, optimize=false, observation=nothing)
    timesteps = size(forcing)[1]
    models = info.tem.models # put the selected models here
    # runSpinupTEM : runspinup

    # runCoreTEM: use the output of spinup to do forward run
end




