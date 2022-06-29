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
    push!(all_options, varlist)
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
    Table((; Pair.([:variable, defNames...], all_options)...))
end

function setupOptimization(info)
    costOpt = getCostOptions(info.opti)
    info = setTupleField(info, (:optim, (;)))

    # set information related to cost metrics for each variable
    info = setTupleSubfield(info, :optim, (:costOptions, costOpt))
    info = setTupleSubfield(info, :optim, (:variables2constrain, info.opti.variables2constrain))
    info = setTupleSubfield(info, :optim, (:multiConstraintMethod, Symbol(info.opti.multiConstraintMethod)))

    # set the list of paramaters to be optimized
    info = setTupleSubfield(info, :optim, (:optimized_paramaters, info.opti.optimized_paramaters))

    # set algorithm related options
    tmp_algorithm = (;)
    algo_method = info.opti.algorithm.package * "_" * info.opti.algorithm.method
    tmp_algorithm = setTupleField(tmp_algorithm, (:method, Symbol(algo_method)))
    tmp_algorithm = setTupleField(tmp_algorithm, (:isMultiObj, info.opti.algorithm.isMultiObj))
    if length(strip(info.opti.algorithm.options_file)) > 0
        options_path = info.opti.algorithm.options_file
        if !isabspath(options_path)
            options_path = joinpath(info.settings_root, options_path)
        end
        options = parsefile(options_path; dicttype=DataStructures.OrderedDict)
        options = typenarrow!(options)
    else
        options = (;)
    end
    tmp_algorithm = setTupleField(tmp_algorithm, (:options, options))
    info = setTupleSubfield(info, :optim, (:algorithm, tmp_algorithm))
    info = setTupleSubfield(info, :optim, (:mapping, info.opti.mapping))

    # get the variables to be used during optimization
    obsVars, optimVars, storeVars = getConstraintNames(info.opti)
    varibInfo = (;)
    varibInfo = setTupleField(varibInfo, (:obs, obsVars))
    varibInfo = setTupleField(varibInfo, (:optim, optimVars))
    varibInfo = setTupleField(varibInfo, (:store, storeVars))
    info = setTupleSubfield(info, :optim, (:variables, (varibInfo)))
    
    return info
end