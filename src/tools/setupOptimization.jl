export getCostOptions, setupOptimization

"""
getCostOptions(optInfo)
info.opti
"""
function getCostOptions(optInfo)
    defNames = Symbol.(keys(optInfo.constraints.defaultCostOptions))
    vals = values(optInfo.constraints.defaultCostOptions)
    defValues = [typeof(v) == String ? Symbol(v) : v for v in vals]

    varlist = Symbol.(optInfo.variables2constrain)
    all_options = []
    for (pn, prop) in enumerate(defNames)
        defProp = defValues[pn]
        vValues = typeof(defProp)[]
        for v in varlist
            optvar = getfield(getfield(optInfo.constraints.variables, v), :costOptions)
            if hasproperty(optvar, prop)
                tmpValue = getfield(optvar, prop)
                push!(vValues, typeof(tmpValue) == String ? Symbol(tmpValue) : tmpValue)
            else
                push!(vValues, defProp)
            end
        end
        push!(all_options, vValues)
    end
    Table((; Pair.(defNames, all_options)...))
end

function setupOptimization(info)
    costOpt = getCostOptions(info.opti)
    info = setTupleField(info, (:optim, (;)))
    info = setTupleSubfield(info, :optim, (:costOptions, costOpt))
    info = setTupleSubfield(info, :optim, (:variables2constrain, info.opti.variables2constrain))
    info = setTupleSubfield(info, :optim, (:params2opti, info.opti.params2opti))
    info = setTupleSubfield(info, :optim, (:algorithm, info.opti.algorithm))

    obsVars, optimVars, storeVars = getConstraintNames(info.opti, info.modelRun.output.variables.store)
    varibInfo = (;)
    varibInfo = setTupleField(varibInfo, (:obs, obsVars))
    varibInfo = setTupleField(varibInfo, (:optim, optimVars))
    varibInfo = setTupleField(varibInfo, (:store, storeVars))

    info = setTupleSubfield(info, :optim, (:variables, (varibInfo)))
    return info
end