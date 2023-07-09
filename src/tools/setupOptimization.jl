export getCostOptions, setupOptimization
export getConstraintNames

"""
    getConstraintNames(info)

returns

  - obsVariables: a list of observation variables that will be used to calculate cost
  - optimVariables: a dictionary of model variables (with land subfields and sub-sub fields) to compare against the observations
  - storeVariables: a dictionary of model variables for which the time series will be stored in memory after the forward run
"""
function getConstraintNames(optim::NamedTuple)
    obsVariables = Symbol.(optim.variables_to_constrain)
    modelVariables = String[]
    optimVariables = (;)
    for v ∈ obsVariables
        vinfo = getproperty(optim.constraints.variables, v)
        push!(modelVariables, vinfo.model_full_var)
        vf, vvar = Symbol.(split(vinfo.model_full_var, "."))
        optimVariables = setTupleField(optimVariables, (v, tuple(vf, vvar)))
    end
    # optimVariables = getVariableGroups(modelVariables)
    storeVariables = getVariableGroups(modelVariables)
    return obsVariables, optimVariables, storeVariables, modelVariables
end

"""
getCostOptions(optInfo)
info.opti
"""
function getCostOptions(optInfo::NamedTuple, varibInfo, number_helpers)
    defNames = Symbol.(keys(optInfo.constraints.default_cost))
    vals = values(optInfo.constraints.default_cost)
    defValues = [v isa String ? Val(Symbol(v)) : v for v ∈ vals]

    varlist = Symbol.(optInfo.variables_to_constrain)
    all_options = []
    push!(all_options, varlist)
    for (pn, prop) ∈ enumerate(defNames)
        defProp = defValues[pn]
        if (defProp isa Number) && !(defProp isa Bool)
            defProp = number_helpers.sNT(defProp)
        end
        vValues = []
        # vValues = typeof(defProp)[]
        for v ∈ varlist
            optvar = getfield(getfield(optInfo.constraints.variables, v), :cost_options)
            if hasproperty(optvar, prop)
                tmpValue = getfield(optvar, prop)
                if (tmpValue isa Number) && !(tmpValue isa Bool)
                    tmpValue = number_helpers.sNT(tmpValue)
                end
                push!(vValues, tmpValue isa String ? Val(Symbol(tmpValue)) : tmpValue)
            else
                push!(vValues, defProp)
            end
        end
        push!(all_options, vValues)
    end
    mod_vars = varibInfo.model
    mod_field = [Symbol(split(_a, ".")[1]) for _a in mod_vars]
    mod_subfield = [Symbol(split(_a, ".")[2]) for _a in mod_vars]
    mod_ind = collect(1:length(varlist))
    obs_ind = [i + 2 * (i - 1) for i in mod_ind]
    push!(all_options, obs_ind)
    push!(all_options, mod_ind)
    push!(all_options, mod_field)
    push!(all_options, mod_subfield)
    return Table((; Pair.([:variable, defNames..., :obs_ind, :mod_ind, :mod_field, :mod_subfield], all_options)...))
end

"""
    checkOptimizedParametersInModels(info::NamedTuple)

checks if the parameters listed in optimized_parameters of opti.json exists in the selected model structure of model_structure.json
"""
function checkOptimizedParametersInModels(info::NamedTuple)
    # @show info.opti.constraints, info.opti.optimized_parameters
    tblParams = getParameters(info.tem.models.forward,
        info.opti.default_parameter,
        info.opti.optimized_parameters)
    model_parameters = tblParams.name_full
    optim_parameters = info.opti.optimized_parameters
    op_names = nothing
    if typeof(optim_parameters) <: Vector
        op_names = optim_parameters
    else
        op_names = replace_comman_separator_in_params(keys(optim_parameters))
    end

    for omp ∈ eachindex(op_names)
        if op_names[omp] ∉ model_parameters
            @warn "Model Inconsistency: the parameter $(op_names[omp]) does not exist in the selected model structure."
            @show model_parameters
            error(
                "Cannot continue with the model inconsistency. Either delete the invalid parameters in optimized_parameters of opti.json, or check model structure to provide correct parameter name"
            )
        end
    end
end

function setupOptimization(info::NamedTuple)
    info = setTupleField(info, (:optim, (;)))

    # set information related to cost metrics for each variable
    info = setTupleSubfield(info, :optim, (:default_parameter, info.opti.default_parameter))
    info = setTupleSubfield(info, :optim, (:variables_to_constrain, info.opti.variables_to_constrain))
    info = setTupleSubfield(info,
        :optim,
        (:multi_constraint_method, Val(Symbol(info.opti.multi_constraint_method))))

    # check and set the list of parameters to be optimized
    checkOptimizedParametersInModels(info)
    info = setTupleSubfield(info, :optim, (:optimized_parameters, info.opti.optimized_parameters))

    # set algorithm related options
    tmp_algorithm = (;)
    algo_method = info.opti.algorithm.package * "_" * info.opti.algorithm.method
    tmp_algorithm = setTupleField(tmp_algorithm, (:method, Val(Symbol(algo_method))))
    tmp_algorithm = setTupleField(tmp_algorithm, (:is_multiple_objective, info.opti.algorithm.is_multiple_objective))
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
    info = setTupleSubfield(info, :optim, (:mapping, info.model_run.mapping))

    # get the variables to be used during optimization
    obsVars, optimVars, storeVars, modelVars = getConstraintNames(info.opti)
    varibInfo = (;)
    varibInfo = setTupleField(varibInfo, (:obs, obsVars))
    varibInfo = setTupleField(varibInfo, (:optim, optimVars))
    varibInfo = setTupleField(varibInfo, (:store, storeVars))
    varibInfo = setTupleField(varibInfo, (:model, modelVars))
    info = setTupleSubfield(info, :optim, (:variables, (varibInfo)))
    costOpt = getCostOptions(info.opti, varibInfo, info.tem.helpers.numbers)
    info = setTupleSubfield(info, :optim, (:cost_options, costOpt))

    return info
end