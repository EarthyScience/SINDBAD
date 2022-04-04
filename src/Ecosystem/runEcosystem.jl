"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out, modelInfo)
    for model in models
        out = Models.compute(model, forcing, out, modelInfo)
        out = Models.update(model, forcing, out, modelInfo)
    end
    return out
end

function runPrecomute(forcing, models, out, modelInfo)
    for model in models
        out = Models.precompute(model, forcing, out, modelInfo)
    end
    return out
end
"""
runForward(selectedModels, forcing, out, modelInfo)
"""
function runForward(selectedModels, forcing, out, modelnames, modelInfo)
    tsteps = size(forcing, 1)
    outtemp = []
    modelnames = tuple(modelnames...)
    for t in 1:tsteps
        out = runModels(forcing[t], selectedModels, out, modelInfo)
        push!(outtemp, NamedTuple{modelnames}(out.fluxes))
    end

    """ # proposed by fabian
    modelnames = (modelnames...,)
    outtemp = map(forcing) do f
        out = runModels(f, selectedModels, out, modelInfo)
        NamedTuple{modelnames}(out.fluxes)
    end
    """

    #outtuples = [runModels(forcing[t], selectedModels, out, info) for t in 1:size(forcing, 1)]
    return columntable(outtemp)
end


"""
runSpinup(selectedModels, initPools, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, initPools, forcing, modelInfo, history=false; nspins=3)
    out=(; pools=(;), diagnostics=(;), fluxes=(;))
    out = (; out..., pools = (; out.pools..., initPools...))
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(initPools)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], selectedModels, out, modelInfo)
            if history
                push!(spinuplog, values(out)[1:length(initPools)])
            end
        end
    end
    return (out, spinuplog)
end

"""
runEcosystem(selectedModels, initPools, forcing, history=false; nspins=3) # forward run
"""
function runEcosystem(selectedModels, initPools, forcing, modelnames, modelInfo, history=false; nspins=3) # forward run
    out, outlog = runSpinup(selectedModels, initPools, forcing, modelInfo, history; nspins=nspins)
    return runForward(selectedModels, forcing, out, modelnames, modelInfo)
end