"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out)
    for m in models
        out = Models.compute(m, forcing, out)
        # out = Models.update(m, forcing, out)
    end
    return out
end

"""
runForward(selectedModels, forcing, out)
"""
function runForward(selectedModels, forcing, out)
    outtuples = [runModels(forcing[t], selectedModels, out) for t in 1:size(forcing, 1)]
    return columntable(outtuples)
end

"""
runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
    out = initStates
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(initStates)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], selectedModels, out)
            if history
                push!(spinuplog, values(out)[1:length(initStates)])
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
    return runForward(selectedModels, forcing, out)
end