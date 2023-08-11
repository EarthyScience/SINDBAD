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
    getAggrFunc(func_name::String)

return a function for a given name to aggregate
"""
function getAggrFunc(func_name::String)
    if func_name == "nanmean"
        return nanmean
    elseif func_name == "nansum"
        return nansum
    elseif func_name == "sum"
        return sum
    else func_name == "mean"
        return mean
    end
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

    varlist = Symbol.(optInfo.observational_constraints)
    # all_options = []
    agg_type = []
    time_aggrs = []
    aggr_funcs = []
    all_costs = map(varlist) do v
        getCombinedNamedTuple(optInfo.observations.default_cost, getfield(getfield(optInfo.observations.variables, v), :cost_options))
    end
    all_options = []
    push!(all_options, varlist)
    prop_names = keys(all_costs[1])
    props_to_keep = (:cost_metric, :area_weight, :cost_weight, :temporal_data_aggr, :aggr_obs, :aggr_order, :min_data_points, :spatial_data_aggr, :spatial_cost_aggr, :aggr_func,)
    for (pn, prop) ∈ enumerate(props_to_keep)
        vValues = []
        for vn ∈ eachindex(varlist)
            sel_opt=all_costs[vn]
            sel_value = sel_opt[prop]
            if (sel_value isa Number) && !(sel_value isa Bool)
                sel_value = number_helpers.sNT(sel_value)
            elseif sel_value isa Bool
                sel_value=getTypeInstanceForOptimizationFlags(prop, sel_value, "Do")
            elseif sel_value isa String && (prop ∉ (:aggr_func, :temporal_data_aggr))
                sel_value = getTypeInstanceForCostMetric(sel_value)
            end
            push!(vValues, sel_value)
            if prop == :temporal_data_aggr
                t_a = sel_value
                to_push_type = TimeNoDiff()
                if endswith(t_a, "_anomaly") || endswith(t_a, "_iav")
                    to_push_type = TimeDiff()
                end
                push!(agg_type, to_push_type)
                push!(time_aggrs, sel_value)
            end
            if prop == :aggr_func
                push!(aggr_funcs, sel_value)
            end
        end
        if prop in props_to_keep
            push!(all_options, vValues)
        end
    end
    mod_vars = varibInfo.model
    mod_field = [Symbol(split(_a, ".")[1]) for _a in mod_vars]
    mod_subfield = [Symbol(split(_a, ".")[2]) for _a in mod_vars]
    mod_ind = collect(1:length(varlist))
    obs_ind = [i + 2 * (i - 1) for i in mod_ind]

    agg_indices = []
    for (i, _aggr) in enumerate(time_aggrs)
        aggr_func = getAggrFunc(aggr_funcs[i])
        _aggrName = string(_aggr)
        skip_aggregation = false
        if startswith(_aggrName, dates_helpers.temporal_resolution)
            skip_aggregation = true
        end
        aggInd = createTimeAggregator(dates_helpers.range, _aggr, aggr_func, skip_aggregation)
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
    push!(all_options, [Any for _ in 1:length(obs_ind)])
    all_props = [:variable, props_to_keep..., :ind, :obs_ind, :mod_ind, :mod_field, :mod_subfield, :temporal_aggr, :temporal_aggr_type, :loss, :valids]
    return Table((; Pair.(all_props, all_options)...))

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
    getTypeInstanceForSpinupMode(mode_name)

a helper function to get the type for spinup mode
"""
function getTypeInstanceForCostMetric(option_name::String)
    opt_ss = join(uppercasefirst.(split(option_name,"_")))
    struct_instance = getfield(SindbadMetrics, Symbol(opt_ss))()
    return struct_instance
end

"""
    getTypeInstanceForSpinupMode(mode_name)

a helper function to get the type for spinup mode
"""
function getTypeInstanceForOptimizationOptions(option_name::String)
    opt_ss = join(uppercasefirst.(split(option_name,"_")))
    struct_instance = getfield(SindbadSetup, Symbol(opt_ss))()
    return struct_instance
end


"""
    getTypeInstanceForSpinupMode(mode_name)

a helper function to get the type for spinup mode
"""
function getTypeInstanceForOptimizationFlags(option_name::Symbol, option_value, opt_pref="Do")
    opt_s = string(option_name)
    opt_ss = join(uppercasefirst.(split(opt_s,"_")))
    if option_value
        structname = opt_pref*opt_ss
    else
        structname = opt_pref*"Not"*opt_ss
    end
    struct_instance = getfield(SindbadSetup, Symbol(structname))()
    return struct_instance
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
        (:multi_constraint_method, getTypeInstanceForOptimizationOptions(info.optimization.multi_constraint_method)))

    # check and set the list of parameters to be optimized
    checkOptimizedParametersInModels(info)
    info = setTupleSubfield(info, :optim, (:model_parameters_to_optimize, info.optimization.model_parameters_to_optimize))

    # set algorithm related options
    tmp_algorithm = (;)
    tmp_algorithm = setTupleField(tmp_algorithm, (:multi_objective_algorithm, getTypeInstanceForOptimizationFlags(:multi_objective_algorithm, info.optimization.multi_objective_algorithm, "Is")))
    optim_algorithm = info.optimization.algorithm
    if endswith(optim_algorithm, ".json")
        options_path = optim_algorithm
        if !isabspath(options_path)
            options_path = joinpath(info.settings_root, options_path)
        end
        options = parsefile(options_path; dicttype=DataStructures.OrderedDict)
        options = dictToNamedTuple(options)
        algo_method = options.package * "_" * options.method
        tmp_algorithm = setTupleField(tmp_algorithm, (:method, getfield(SindbadSetup, Symbol(algo_method))()))
        tmp_algorithm = setTupleField(tmp_algorithm, (:options, options.options))
    else
        options = (;)
        tmp_algorithm = setTupleField(tmp_algorithm, (:method, getfield(SindbadSetup, Symbol(optim_algorithm))()))
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