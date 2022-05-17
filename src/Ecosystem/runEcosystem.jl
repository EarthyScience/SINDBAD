export runEcosystem, runSpinup, runForward
export removeEmptyFields

"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out, modelHelpers)
    for model in models
        out = Models.compute(model, forcing, out, modelHelpers)
        # out = Models.update(model, forcing, out, modelHelpers)
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
        # fout = setTupleField(fout, (k, v, getfield(out, k)))
        fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
    end
    return fout
end

function runPrecompute(forcing, models, out, modelHelpers)
    for model in models
        out = Models.precompute(model, forcing, out, modelHelpers)
    end
    return out
end

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(forward_models, forcing, out, modelVars, modelHelpers)
    outtemp = map(forcing) do f
        out = runModels(f, forward_models, out, modelHelpers)
        out_filtered = filterVariables(out, modelVars)
        deepcopy(out_filtered)
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
function runSpinup(spinup_models, forcing, out, modelHelpers; history=false, nspins=3)
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(out.pools)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], spinup_models, out, modelHelpers)
            if history
                push!(spinuplog, values(deepcopy(out))[1:length(out.pools)])
            end
        end
    end
    return (out, spinuplog)
end

"""
runEcosystem(selectedModels, initPools, forcing, history=false; nspins=3) # forward run
"""
function runEcosystem(approaches, forcing, init_out, modelInfo, history=false; nspins=3) # forward run
    spinup_models = approaches[modelInfo.models.is_spinup .== 1]
    out_prec = runPrecompute(forcing[1], approaches, init_out, modelInfo.helpers)
    out_spin, spinuplog = runSpinup(spinup_models, forcing, out_prec, modelInfo.helpers; history, nspins=nspins)
    out_forw = runForward(approaches, forcing, out_spin, modelInfo.variables, modelInfo.helpers)
    out_forw = removeEmptyFields(out_forw)
    return out_forw
end