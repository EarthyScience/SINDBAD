"""
runModels(forcing, models, diagflux, states, info)
"""
function runModels(forcing, models, diagflux, states, info)
    for m in models
        out = Models.compute(m, forcing, diagflux, states, info)
        # out = Models.update(m, forcing, diagflux, states, info)
    end
    return out
end

"""
runForward(selectedModels, forcing, diagflux, states, info)
"""
function runForward(selectedModels, forcing, diagflux, states, info)
    outtuples = [runModels(forcing[t], selectedModels, diagflux, states, info) for t in 1:size(forcing, 1)]
    return columntable(outtuples)
end

"""
runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
    out = initStates
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(diagflux, states, info)[1:length(initStates)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], selectedModels, diagflux, states, info)
            if history
                push!(spinuplog, values(diagflux, states, info)[1:length(initStates)])
            end
        end
    end
    return (out, spinuplog)
end

"""
runEcosystem(selectedModels, initStates, forcing, history=false; nspins=3) # forward run
"""
function runEcosystem(selectedModels, initStates, forcing, history=false; nspins=3) # forward run
    out, outlog = runSpinup(selectedModels, initStates, forcing, history; nspins=nspins)
    return runForward(selectedModels, forcing, diagflux, states, info)
end