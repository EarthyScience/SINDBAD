export getConstraintNames
export getCostOptions
export setOptim


"""
    checkOptimizedParametersInModels(info::NamedTuple)

checks if the parameters listed in model_parameters_to_optimize of optimization.json exists in the selected model structure of model_structure.json
"""
function checkOptimizedParametersInModels(info::NamedTuple)
    # @show info.optimization.observations, info.optimization.model_parameters_to_optimize
    tbl_params = getParameters(info.tem.models.forward,
        info.optimization.model_parameter_default,
        info.optimization.model_parameters_to_optimize,
        info.tem.helpers.numbers.sNT)
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
    getCostOptions(optim_info::NamedTuple, vars_info, number_helpers, dates_helpers)



# Arguments:
- `optim_info`: DESCRIPTION
- `vars_info`: DESCRIPTION
- `number_helpers`: DESCRIPTION
- `dates_helpers`: DESCRIPTION
"""
function getCostOptions(optim_info::NamedTuple, vars_info, tem_variables, number_helpers, dates_helpers)
    varlist = Symbol.(optim_info.observational_constraints)
    agg_type = []
    time_aggrs = []
    aggr_funcs = []
    all_costs = map(varlist) do v
        getCombinedNamedTuple(optim_info.observations.default_cost, getfield(getfield(optim_info.observations.variables, v), :cost_options))
    end
    all_options = []
    push!(all_options, varlist)
    prop_names = keys(all_costs[1])
    props_to_keep = (:cost_metric, :spatial_weight, :cost_weight, :temporal_data_aggr, :aggr_obs, :aggr_order, :min_data_points, :spatial_data_aggr, :spatial_cost_aggr, :aggr_func,)
    for (pn, prop) ∈ enumerate(props_to_keep)
        prop_array = []
        for vn ∈ eachindex(varlist)
            sel_opt=all_costs[vn]
            sel_value = sel_opt[prop]
            if (sel_value isa Number) && !(sel_value isa Bool)
                sel_value = number_helpers.sNT(sel_value)
            elseif sel_value isa Bool
                sel_value=getTypeInstanceForFlags(prop, sel_value, "Do")
            elseif sel_value isa String && (prop ∉ (:aggr_func, :temporal_data_aggr))
                sel_value = getTypeInstanceForCostMetric(sel_value)
            end
            push!(prop_array, sel_value)
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
            push!(all_options, prop_array)
        end
    end
    mod_vars = vars_info.model
    mod_field = [Symbol(split(_a, ".")[1]) for _a in mod_vars]
    mod_subfield = [Symbol(split(_a, ".")[2]) for _a in mod_vars]
    mod_ind = collect(1:length(varlist))
    obs_ind = [i + 3 * (i - 1) for i in mod_ind]

    mod_ind = [findfirst(s -> first(s) === mf && last(s) === msf, tem_variables) for (mf, msf) in zip(mod_field, mod_subfield)]
    # map(cost_option_table) do cost_option
    #     # @show cost_option
    #     new_mod_ind = findfirst(s -> first(s) === cost_option.mod_field && last(s) === cost_option.mod_subfield, tem_variables)
    #     cost_option = Accessors.@set cost_option.mod_ind = new_mod_ind
    # end

    agg_indices = []
    for (i, _aggr) in enumerate(time_aggrs)
        aggr_func = getAggrFunc(aggr_funcs[i])
        _aggr_name = string(_aggr)
        skip_aggregation = false
        if startswith(_aggr_name, dates_helpers.temporal_resolution)
            skip_aggregation = true
        end
        aggInd = createTimeAggregator(dates_helpers.range, _aggr, aggr_func, skip_aggregation)
        push!(agg_indices, aggInd)
    end
    push!(all_options, obs_ind)
    push!(all_options, mod_ind)
    push!(all_options, mod_field)
    push!(all_options, mod_subfield)
    push!(all_options, agg_indices)
    push!(all_options, agg_type)
    all_props = [:variable, props_to_keep..., :obs_ind, :mod_ind, :mod_field, :mod_subfield, :temporal_aggr, :temporal_aggr_type]
    return (; Pair.(all_props, all_options)...)
end


"""
    getConstraintNames(optim::NamedTuple)

- obs_vars: a list of observation variables that will be used to calculate cost
- optim_vars: a dictionary of model variables (with land subfields and sub-sub fields) to compare against the observations
- storeVariables: a dictionary of model variables for which the time series will be stored in memory after the forward run

"""
function getConstraintNames(optim::NamedTuple)
    obs_vars = Symbol.(optim.observational_constraints)
    model_vars = String[]
    optim_vars = (;)
    for v ∈ obs_vars
        vinfo = getproperty(optim.observations.variables, v)
        push!(model_vars, vinfo.model_full_var)
        vf, vvar = Symbol.(split(vinfo.model_full_var, "."))
        optim_vars = setTupleField(optim_vars, (v, tuple(vf, vvar)))
    end
    store_vars = getVariableGroups(model_vars)
    return obs_vars, optim_vars, store_vars, model_vars
end

function getParamModelIDVal(tbl_params)
    param_names = Symbol.(replace.(tbl_params.name_full, "." => "____"))
    model_id = tbl_params.model_id;
    param_id_tuple=Tuple(map(param_names, model_id) do p,m
        (p, m)
    end)
    return Val(param_id_tuple)
end



"""
    setOptim(info::NamedTuple)


"""
function setOptim(info::NamedTuple)
    info = setTupleField(info, (:optim, (;)))

    # set information related to cost metrics for each variable
    info = setTupleSubfield(info, :optim, (:model_parameter_default, info.optimization.model_parameter_default))
    info = setTupleSubfield(info, :optim, (:observational_constraints, info.optimization.observational_constraints))
    info = setTupleSubfield(info,
        :optim,
        (:multi_constraint_method, getTypeInstanceForNamedOptions(info.optimization.multi_constraint_method)))

    # check and set the list of parameters to be optimized
    checkOptimizedParametersInModels(info)
    info = setTupleSubfield(info, :optim, (:model_parameters_to_optimize, info.optimization.model_parameters_to_optimize))

    # set algorithm related options
    tmp_algorithm = (;)
    tmp_algorithm = setTupleField(tmp_algorithm, (:multi_objective_algorithm, getTypeInstanceForFlags(:multi_objective_algorithm, info.optimization.multi_objective_algorithm, "Is")))
    optim_algorithm = info.optimization.algorithm
    if endswith(optim_algorithm, ".json")
        options_path = optim_algorithm
        if !isabspath(options_path)
            options_path = joinpath(info.settings_root, options_path)
        end
        options = parsefile(options_path; dicttype=DataStructures.OrderedDict)
        options = dictToNamedTuple(options)
        algo_method = options.package * "_" * options.method
        tmp_algorithm = setTupleField(tmp_algorithm, (:method, getTypeInstanceForNamedOptions(algo_method)))
        tmp_algorithm = setTupleField(tmp_algorithm, (:options, options.options))
    else
        options = (;)
        tmp_algorithm = setTupleField(tmp_algorithm, (:method, getTypeInstanceForNamedOptions(info.optimization.algorithm)))
        tmp_algorithm = setTupleField(tmp_algorithm, (:options, options))
    end
    info = setTupleSubfield(info, :optim, (:algorithm, tmp_algorithm))

    tbl_params = getParameters(info.tem.models.forward,
    info.optimization.model_parameter_default,
    info.optimization.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);

    param_model_id_val = getParamModelIDVal(tbl_params)
    info = setTupleSubfield(info, :optim, (:param_model_id_val, param_model_id_val))

    # get the variables to be used during optimization
    obs_vars, optim_vars, store_vars, model_vars = getConstraintNames(info.optimization)
    vars_info = (;)
    vars_info = setTupleField(vars_info, (:obs, obs_vars))
    vars_info = setTupleField(vars_info, (:optim, optim_vars))
    vars_info = setTupleField(vars_info, (:store, store_vars))
    vars_info = setTupleField(vars_info, (:model, model_vars))
    info = setTupleSubfield(info, :optim, (:variables, (vars_info)))
    info = updateVariablesToStore(info)
    cost_options = getCostOptions(info.optimization, vars_info, info.tem.variables, info.tem.helpers.numbers, info.tem.helpers.dates)
    info = setTupleSubfield(info, :optim, (:cost_options, cost_options))
    return info
end


