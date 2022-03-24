"""
runModels(forcing, models, out, info)
"""
function runModels(forcing, models, out, info)
    for model in models
        out = Models.compute(model, forcing, out, info)
        out = Models.update(model, forcing, out, info)
        # @show out
        # out = Models.update(m, forcing, out, info)
    end
    return out
end

"""
runForward(selectedModels, forcing, out, info)
"""
function runForward(selectedModels, forcing, out, info)
    outtuples = [runModels(forcing[t], selectedModels, out, info) for t in 1:size(forcing, 1)]
    return columntable(outtuples)
end

"""
runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, initStates, forcing, info, history=false; nspins=3)
    out=(; states=(;), diagnostics=(;), fluxes=(;))
    out = (; out..., states = (; out.states..., initStates...))
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(initStates)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], selectedModels, out, info)
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
function runEcosystem(selectedModels, initStates, forcing, info, history=false; nspins=3) # forward run
    out, outlog = runSpinup(selectedModels, initStates, forcing, info, history; nspins=nspins)
    return runForward(selectedModels, forcing, out, info)
end