export getConstraintNames
export getCostOptions
export setupOptimization



"""
    checkOptimizedParametersInModels(info::NamedTuple)

checks if the parameters listed in model_parameters_to_optimize of optimization.json exists in the selected model structure of model_structure.json
"""
function checkOptimizedParametersInModels(info::NamedTuple)
    # @show info.optimization.observations, info.optimization.model_parameters_to_optimize
    tbl_params = getParameters(info.tem.models.forward,
        info.optimization.model_parameter_default,
        info.optimization.model_parameters_to_optimize)
    model_parameters = tbl_params.name_full
    # @show model_parameters
    optim_parameters = info.optimization.model_parameters_to_optimize
    op_names = nothing
    if typeof(optim_parameters) <: Vector
        op_names = replaceCommaSeparatorParams(optim_parameters)
    else
        op_names = replaceCommaSeparatorParams(keys(optim_parameters))
    end

    for omp ∈ eachindex(op_names)
        if op_names[omp] ∉ model_parameters
            @warn "Model Inconsistency: the parameter $(op_names[omp]) does not exist in the selected model structure."
            @show model_parameters
            error(
                "Cannot continue with the model inconsistency. Either delete the invalid parameters in model_parameters_to_optimize of optimization.json, or check model structure to provide correct parameter name"
            )
        end
    end
end

"""
    getAggrFunc(Val{:mean})

DOCSTRING
"""
function getAggrFunc(::Val{:mean})
    return Sindbad.mean
end

"""
    getAggrFunc(Val{:sum})

DOCSTRING
"""
function getAggrFunc(::Val{:sum})
    return Sindbad.sum
end

"""
    getAggrFunc(Val{:nanMean})

DOCSTRING
"""
function getAggrFunc(::Val{:nanMean})
    return Sindbad.nanMean
end

"""
    getAggrFunc(Val{:nanSum})

DOCSTRING
"""
function getAggrFunc(::Val{:nanSum})
    return Sindbad.nanSum
end



"""
    getCostOptions(optInfo::NamedTuple, varibInfo, number_helpers, dates_helpers)

DOCSTRING

# Arguments:
- `optInfo`: DESCRIPTION
- `varibInfo`: DESCRIPTION
- `number_helpers`: DESCRIPTION
- `dates_helpers`: DESCRIPTION
"""
function getCostOptions(optInfo::NamedTuple, varibInfo, number_helpers, dates_helpers)
    defNames = Symbol.(keys(optInfo.observations.default_cost))
    vals = values(optInfo.observations.default_cost)
    defValues = [v isa String ? Val(Symbol(v)) : v for v ∈ vals]

    varlist = Symbol.(optInfo.observational_constraints)
    all_options = []
    agg_type = []
    time_aggrs = []
    aggr_funcs = []

    push!(all_options, varlist)
    for (pn, prop) ∈ enumerate(defNames)
        defProp = defValues[pn]
        if (defProp isa Number) && !(defProp isa Bool)
            defProp = number_helpers.sNT(defProp)
        end
        vValues = []
        # vValues = typeof(defProp)[]
        for v ∈ varlist
            optvar = getfield(getfield(optInfo.observations.variables, v), :cost_options)
            if hasproperty(optvar, prop)
                tmpValue = getfield(optvar, prop)
                if (tmpValue isa Number) && !(tmpValue isa Bool)
                    tmpValue = number_helpers.sNT(tmpValue)
                end
                push!(vValues, tmpValue isa String ? Val(Symbol(tmpValue)) : tmpValue)
            else
                push!(vValues, defProp)
            end
            if prop == :temporal_aggr
                t_a = string(valToSymbol(vValues[end]))
                to_push_type = Val(:no_diff)
                if endswith(t_a, "_anomaly") || endswith(t_a, "_iav")
                    to_push_type = Val(:diff)
                end
                push!(agg_type, to_push_type)
                push!(time_aggrs, valToSymbol(vValues[end]))
            end
            if prop == :temporal_aggr_func
                push!(aggr_funcs, valToSymbol(vValues[end]))
            end
        end
        push!(all_options, vValues)
    end
    mod_vars = varibInfo.model
    mod_field = [Symbol(split(_a, ".")[1]) for _a in mod_vars]
    mod_subfield = [Symbol(split(_a, ".")[2]) for _a in mod_vars]
    mod_ind = collect(1:length(varlist))
    obs_ind = [i + 2 * (i - 1) for i in mod_ind]

    agg_indices = []
    for (i, _aggr) in enumerate(time_aggrs)
        aggr_func = getAggrFunc(Val(aggr_funcs[i]))
        _aggrName = string(_aggr)
        is_model_timestep = false
        if startswith(_aggrName, dates_helpers.temporal_resolution)
            is_model_timestep = true
        end
        aggInd = createTimeAggregator(dates_helpers.range, Val(_aggr), aggr_func, is_model_timestep)
        push!(agg_indices, aggInd)
    end
    push!(all_options, 1:length(obs_ind))
    push!(all_options, obs_ind)
    push!(all_options, mod_ind)
    push!(all_options, mod_field)
    push!(all_options, mod_subfield)
    push!(all_options, agg_indices)
    push!(all_options, agg_type)
    push!(all_options, number_helpers.sNT.(zero(mod_ind)))
    return Table((; Pair.([:variable, defNames..., :ind, :obs_ind, :mod_ind, :mod_field, :mod_subfield, :temporal_aggregator, :temporal_aggr_type, :loss], all_options)...))
end

"""
    getConstraintNames(optim::NamedTuple)

- obsVariables: a list of observation variables that will be used to calculate cost
- optimVariables: a dictionary of model variables (with land subfields and sub-sub fields) to compare against the observations
- storeVariables: a dictionary of model variables for which the time series will be stored in memory after the forward run

"""
function getConstraintNames(optim::NamedTuple)
    obsVariables = Symbol.(optim.observational_constraints)
    modelVariables = String[]
    optimVariables = (;)
    for v ∈ obsVariables
        vinfo = getproperty(optim.observations.variables, v)
        push!(modelVariables, vinfo.model_full_var)
        vf, vvar = Symbol.(split(vinfo.model_full_var, "."))
        optimVariables = setTupleField(optimVariables, (v, tuple(vf, vvar)))
    end
    # optimVariables = getVariableGroups(modelVariables)
    storeVariables = getVariableGroups(modelVariables)
    return obsVariables, optimVariables, storeVariables, modelVariables
end

"""
    setupOptimization(info::NamedTuple)

DOCSTRING
"""
function setupOptimization(info::NamedTuple)
    info = setTupleField(info, (:optim, (;)))

    # set information related to cost metrics for each variable
    info = setTupleSubfield(info, :optim, (:model_parameter_default, info.optimization.model_parameter_default))
    info = setTupleSubfield(info, :optim, (:observational_constraints, info.optimization.observational_constraints))
    info = setTupleSubfield(info,
        :optim,
        (:multi_constraint_method, Val(Symbol(info.optimization.multi_constraint_method))))

    # check and set the list of parameters to be optimized
    checkOptimizedParametersInModels(info)
    info = setTupleSubfield(info, :optim, (:model_parameters_to_optimize, info.optimization.model_parameters_to_optimize))

    # set algorithm related options
    tmp_algorithm = (;)
    tmp_algorithm = setTupleField(tmp_algorithm, (:multi_objective_algorithm, info.optimization.multi_objective_algorithm))
    optim_algorithm = info.optimization.algorithm
    if endswith(optim_algorithm, ".json")
        options_path = optim_algorithm
        if !isabspath(options_path)
            options_path = joinpath(info.settings_root, options_path)
        end
        options = parsefile(options_path; dicttype=DataStructures.OrderedDict)
        options = dictToNamedTuple(options)
        algo_method = options.package * "_" * options.method
        tmp_algorithm = setTupleField(tmp_algorithm, (:method, Val(Symbol(algo_method))))
        tmp_algorithm = setTupleField(tmp_algorithm, (:options, options.options))
    else
        options = (;)
        tmp_algorithm = setTupleField(tmp_algorithm, (:method, Val(Symbol(optim_algorithm))))
        tmp_algorithm = setTupleField(tmp_algorithm, (:options, options))
    end
    info = setTupleSubfield(info, :optim, (:algorithm, tmp_algorithm))

    # get the variables to be used during optimization
    obsVars, optimVars, storeVars, modelVars = getConstraintNames(info.optimization)
    varibInfo = (;)
    varibInfo = setTupleField(varibInfo, (:obs, obsVars))
    varibInfo = setTupleField(varibInfo, (:optim, optimVars))
    varibInfo = setTupleField(varibInfo, (:store, storeVars))
    varibInfo = setTupleField(varibInfo, (:model, modelVars))
    info = setTupleSubfield(info, :optim, (:variables, (varibInfo)))
    costOpt = getCostOptions(info.optimization, varibInfo, info.tem.helpers.numbers, info.tem.helpers.dates)
    info = setTupleSubfield(info, :optim, (:cost_options, costOpt))

    return info
end