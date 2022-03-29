"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out)
    for model in models
        out = Models.compute(model, forcing, out)
        out = Models.update(model, forcing, out)
        # @show out
        # out = Models.update(m, forcing, out)
    end
    return out
end

"""
runForward(selectedModels, forcing, out)
"""
function runForward(selectedModels, forcing, out, modelnames)
    tsteps = size(forcing, 1)
    outtemp = []
    modelnames = tuple(modelnames...)
    for t in 1:tsteps
        out = runModels(forcing[t], selectedModels, out)
        push!(outtemp, NamedTuple{modelnames}(out.fluxes))
    end
    #outtuples = [runModels(forcing[t], selectedModels, out, info) for t in 1:size(forcing, 1)]
    return columntable(outtemp)
end


"""
runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, initStates, forcing, history=false; nspins=3)
    out=(; states=(;), diagnostics=(;), fluxes=(;))
    out = (; out..., states = (; out.states..., initStates...))
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
function runEcosystem(selectedModels, initStates, forcing, modelnames, history=false; nspins=3) # forward run
    out, outlog = runSpinup(selectedModels, initStates, forcing, history; nspins=nspins)
    return runForward(selectedModels, forcing, out, modelnames)
end