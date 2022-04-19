"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out, modelInfo)
    for model in models
        out = Models.compute(model, forcing, out, modelInfo)
        out = Models.update(model, forcing, out, modelInfo)
        # @show typeof(model), out.pools.soilW
    end
    return out
end

function runPrecompute(forcing, models, out, modelInfo)
    for model in models
        out = Models.precompute(model, forcing, out, modelInfo)
    end
    return out
end

"""
runForward(selectedModels, forcing, out, infotem)
"""
function runForward(selectedModels, forcing, out, modelnames, modelInfo)
    modelnames = (modelnames...,)
    outtemp = map(forcing) do f
        out = runModels(f, selectedModels, out, modelInfo)
        NamedTuple{modelnames}(out.fluxes)
    end
    return columntable(outtemp)
end


"""
getInitOut(initPools)
create the initial out tuple with all models
"""
function getInitOut(initPools, selectedModels)
    out = (;)
    out = (; out..., pools=(;), states=(;), fluxes=(;))
    out = (; out..., pools=(; out.pools..., initPools...))
    # @show selectedModels, string.(selectedModels)
    sortedModels = sort([_sm for _sm in selectedModels])
    for model in sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out

end


"""
runSpinup(selectedModels, initPools, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, initPools, forcing, modelInfo, history=false; nspins=3)
    out = getInitOut(initPools, modelInfo.models.selected_models)
    # out=(; pools=(;), diagnostics=(;), fluxes=(;))
    # out = (; out..., pools = (; out.pools..., initPools...))
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(initPools)]] : nothing
    out = runPrecompute(forcing[1], selectedModels, out, modelInfo)
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