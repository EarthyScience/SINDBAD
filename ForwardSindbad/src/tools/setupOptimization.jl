export getCostOptions, setupOptimization

"""
getCostOptions(optInfo)
info.opti
"""
function getCostOptions(optInfo::NamedTuple)
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

"""
    checkOptimizedParametersInModels(info::NamedTuple)
checks if the parameters listed in optimized_parameters of opti.json exists in the selected model structure of modelStructure.json
"""
function checkOptimizedParametersInModels(info::NamedTuple)
    model_parameters = getParameters(info.tem.models.forward, info.opti.optimized_parameters).varsModels;
    optim_parameters = info.opti.optimized_parameters
    for omp in eachindex(optim_parameters)
        if optim_parameters[omp] ∉ model_parameters
            @warn "Model Inconsistency: the parameter $(optim_parameters[omp]) does not exist in the selected model structure."
            @show model_parameters
            error("Cannot continue with the model inconsistency. Either delete the invalid parameters in optimized_parameters of opti.json, or check model structure to provide correct parameter name")
        end
    end
end

function setupOptimization(info::NamedTuple)
    costOpt = getCostOptions(info.opti)
    info = setTupleField(info, (:optim, (;)))

    # set information related to cost metrics for each variable
    info = setTupleSubfield(info, :optim, (:costOptions, costOpt))
    info = setTupleSubfield(info, :optim, (:variables2constrain, info.opti.variables2constrain))
    info = setTupleSubfield(info, :optim, (:multiConstraintMethod, Symbol(info.opti.multiConstraintMethod)))

    # check and set the list of parameters to be optimized
    checkOptimizedParametersInModels(info)
    info = setTupleSubfield(info, :optim, (:optimized_parameters, info.opti.optimized_parameters))

    # set algorithm related options
    tmp_algorithm = (;)
    algo_method = info.opti.algorithm.package * "_" * info.opti.algorithm.method
    tmp_algorithm = setTupleField(tmp_algorithm, (:method, Symbol(algo_method)))
    tmp_algorithm = setTupleField(tmp_algorithm, (:isMultiObj, info.opti.algorithm.isMultiObj))
    if !isnothing(info.opti.algorithm.options_file)
        options_path = info.opti.algorithm.options_file
        if !isabspath(options_path)
            options_path = joinpath(info.settings_root, options_path)
        end
        options = parsefile(options_path; dicttype=DataStructures.OrderedDict)
        options = dictToNamedTuple(options)
    else
        options = (;)
    end
    tmp_algorithm = setTupleField(tmp_algorithm, (:options, options))
    info = setTupleSubfield(info, :optim, (:algorithm, tmp_algorithm))
    info = setTupleSubfield(info, :optim, (:mapping, info.modelRun.mapping))

    # get the variables to be used during optimization
    obsVars, optimVars, storeVars = getConstraintNames(info.opti)
    varibInfo = (;)
    varibInfo = setTupleField(varibInfo, (:obs, obsVars))
    varibInfo = setTupleField(varibInfo, (:optim, optimVars))
    varibInfo = setTupleField(varibInfo, (:store, storeVars))
    info = setTupleSubfield(info, :optim, (:variables, (varibInfo)))
    
    return info
end