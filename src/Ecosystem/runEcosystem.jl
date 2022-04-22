export runEcosystem, runSpinup, runForward, showoutr
"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out, modelHelpers)
    for model in models
        out = Models.compute(model, forcing, out, modelHelpers)
        # out = Models.update(model, forcing, out, modelHelpers)
        # @show typeof(model), typeof(out.pools.soilW), typeof(out.pools.snowW)
    end
    return out
end

"""
filterVariables(out::NamedTuple, varsinfo)
"""
function filterVariables(out::NamedTuple, varsinfo)
    fout = (;)
    for k in keys(varsinfo)
        v = getfield(varsinfo, k)
        fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
    end
    return fout
end

function runPrecompute(forcing, models, out, modelHelpers)
    for model in models
        out = Models.precompute(model, forcing, out, modelHelpers)
        # @show typeof(model), typeof(out.pools.soilW), typeof(out.pools.snowW)
        # println("-------------------")
    end
    return out
end

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(selectedModels, forcing, out, modelVars, modelHelpers)
    # modelVars = (modelVars...,)
    outtemp = map(forcing) do f
        out = runModels(f, selectedModels, out, modelHelpers)
        filterVariables(out, modelVars)
        # NamedTuple{modelVars}(out.fluxes)
    end
    return columntable(outtemp)
end

"""
removeEmptyFields(tpl)
"""
function removeEmptyFields(tpl)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end

"""
runSpinup(selectedModels, initPools, forcing, history=false; nspins=3)
"""
function runSpinup(selectedModels, forcing, out, modelHelpers, history=false; nspins=3)
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(out.pools)]] : nothing
    out = runPrecompute(forcing[1], selectedModels, out, modelHelpers)
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], selectedModels, out, modelHelpers)
            out = removeEmptyFields(out)
            if history
                push!(spinuplog, values(out)[1:length(out.pools)])
            end
        end
    end
    return (out, spinuplog)
end

"""
runEcosystem(selectedModels, initPools, forcing, history=false; nspins=3) # forward run
"""
function runEcosystem(selectedModels, forcing, out, modelVars, modelInfo, history=false; nspins=3) # forward run
    out, outlog = runSpinup(selectedModels, forcing, out, modelInfo.helpers, history; nspins=nspins)
    return runForward(selectedModels, forcing, out, modelInfo.variables, modelInfo.helpers)
end