function runEcosystem(forcing, models, out)
    for m in models
        out = Models.compute(m, forcing, out)
    end
    return out
end

function runForwardTEM(info, forcing, out, update_timeseries=true)
    timesteps = size(forcing)[1]
    outTime = zeros(timesteps, length(out))
    outTime[1, :] .= values(out)
    for t in 1:timesteps
        out = runEcosystem(forcing[t], info.tem.models.forward, out)
        outTime[t, :] .= values(out)
    end
    namesOut = keys(out)
    valuesOut = [outTime[:, i] for i in 1:length(namesOut)]
    outTable = Table((; zip(namesOut, valuesOut)...))

    if update_timeseries
        # update the fluxes and states.. usually for spinup, we do not need the time series, and so this flag is useful for spinup vs forward run.. may be this chunk needs to be another function because it needs to have option to have the time series of the variables that are listed to be stored in output.json.
        println("not done yet")
    end
    return outTable
end

function initiateStates(wSnow, wSoil)
    out = NamedTuple()
    out = (; out..., wSnow, wSoil) 
    return out
end

function runSpinupTEM(info, forcing)
    ### handle spinup things here
    ### runs
    out = initiateStates(0.01,0.01)
    timesteps = size(forcing)[1]
    out = runEcosystem(forcing[1], info.tem.models.spinup, out) # just tuples ?
    for j in 1:3 ## just 3 repeats of the the spinup.. placeholder for nLoops in spinup.json
        for t in 1:timesteps
            out = runEcosystem(forcing[t], info.tem.models.spinup, out)
        end
    end
    return out
end

function runTEM(info, forcing, optimize=false, observation=nothing)
    # runSpinupTEM : runspinup
    out = runSpinupTEM(info, forcing)

    # runForwardTEM: use the output of spinup to do forward run
    outTab = runForwardTEM(info, forcing, out)

    return outTab

end




