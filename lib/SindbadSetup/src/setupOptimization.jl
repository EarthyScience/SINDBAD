export getConstraintNames
export getCostOptions
export setOptimization


"""
    checkOptimizedParametersInModels(info::NamedTuple, parameter_table)

Checks if the parameters listed in `model_parameters_to_optimize` from `optimization.json` exist in the selected model structure from `model_structure.json`.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.
- `parameter_table`: A table of parameters extracted from the model structure.

# Notes:
- Issues a warning and throws an error if any parameter in `model_parameters_to_optimize` does not exist in the model structure.
"""
function checkOptimizedParametersInModels(info::NamedTuple, parameter_table)
    # @show info.settings.optimization.observations, info.settings.optimization.model_parameters_to_optimize
    model_parameters = parameter_table.name_full
    # @show model_parameters
    optim_parameters = info.settings.optimization.model_parameters_to_optimize
    op_names = nothing
    if typeof(optim_parameters) <: Vector
        op_names = replaceCommaSeparatedParams(optim_parameters)
    else
        op_names = replaceCommaSeparatedParams(keys(optim_parameters))
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

Returns an aggregation function corresponding to the given function name.

# Arguments:
- `func_name`: A string specifying the name of the aggregation function (e.g., "mean", "sum").

# Returns:
- The corresponding aggregation function (e.g., `mean`, `sum`).

# Notes:
- Supports common aggregation functions such as `mean`, `sum`, `nanmean`, and `nansum`.
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
    getCostOptions(optim_info::NamedTuple, vars_info, tem_variables, number_helpers, dates_helpers)

Sets up cost optimization options based on the provided parameters.

# Arguments:
- `optim_info`: A NamedTuple containing optimization parameters and settings.
- `vars_info`: Information about variables used in optimization.
- `tem_variables`: Template variables for optimization setup.
- `number_helpers`: Helper functions or values for numerical operations.
- `dates_helpers`: Helper functions or values for date-related operations.

# Returns:
- A NamedTuple containing cost optimization configuration options.

# Notes:
- Configures temporal and spatial aggregation, cost metrics, and other optimization-related settings.
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
                sel_value = number_helpers.num_type(sel_value)
            elseif sel_value isa Bool
                sel_value=getTypeInstanceForFlags(prop, sel_value, "Do")
            elseif sel_value isa String && (prop ∉ (:aggr_func, :temporal_data_aggr))
                sel_value = getTypeInstanceForCostMetric(sel_value)
            end
            push!(prop_array, sel_value)
            if prop == :temporal_data_aggr
                t_a = sel_value
                to_push_type = TimeNoDiff()
                if endswith(lowercase(t_a), "_anomaly") || endswith(lowercase(t_a), "_iav")
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
    obs_sn = [i for i in mod_ind]
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
    push!(all_options, obs_sn)
    push!(all_options, mod_ind)
    push!(all_options, mod_field)
    push!(all_options, mod_subfield)
    push!(all_options, agg_indices)
    push!(all_options, agg_type)
    all_props = [:variable, props_to_keep..., :obs_ind, :obs_sn, :mod_ind, :mod_field, :mod_subfield, :temporal_aggr, :temporal_aggr_type]
    return (; Pair.(all_props, all_options)...)
end


"""
    getConstraintNames(optim::NamedTuple)

Extracts observation and model variable names for optimization constraints.

# Arguments:
- `optim`: A NamedTuple containing optimization settings and observation constraints.

# Returns:
- A tuple containing:
  - `obs_vars`: A list of observation variables used to calculate cost.
  - `optim_vars`: A lookup mapping observation variables to model variables.
  - `store_vars`: A lookup of model variables for which time series will be stored.
  - `model_vars`: A list of model variable names.
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

"""
    getParamModelIDVal(parameter_table)

Generates a `Val` object containing tuples of parameter names and their corresponding model IDs.

# Arguments:
- `parameter_table`: A table of parameters with their names and model IDs.

# Returns:
- A `Val` object containing tuples of parameter names and model IDs.

# Notes:
- Parameter names are transformed to a unique format by replacing dots with underscores.
"""
function getParamModelIDVal(parameter_table)
    parameter_names = Symbol.(replace.(parameter_table.name_full, "." => "____"))
    model_id = parameter_table.model_id;
    parameter_id_tuple=Tuple(map(parameter_names, model_id) do p,m
        (p, m)
    end)
    return Val(parameter_id_tuple)
end

function setAlgorithmOptions(info, which_algorithm)
    optim_algorithm = getproperty(info.settings.optimization, which_algorithm)
    tmp_algorithm = (;)
    algo_options = (;)
    algo_method = nothing
    if !isnothing(optim_algorithm)
        if endswith(optim_algorithm, ".json")
            options_path = optim_algorithm
            if !isabspath(options_path)
                options_path = joinpath(info.temp.experiment.dirs.settings, options_path)
            end
            options = parsefile(options_path; dicttype=DataStructures.OrderedDict)
            options = dictToNamedTuple(options)
            algo_method = options.package * "_" * options.method
            algo_method = getTypeInstanceForNamedOptions(algo_method)
            algo_options = options.options
        else
            algo_method = getTypeInstanceForNamedOptions(optim_algorithm)
        end
    else
        if which_algorithm == :algorithm_sensitivity_analysis
            algo_method = GlobalSensitivityMorris()
        end
    end
    default_opt = sindbadDefaultOptions(getproperty(SindbadSetup, nameof(typeof(algo_method)))())
    merged_options = mergeNamedTuple(default_opt, algo_options)
    tmp_algorithm = setTupleField(tmp_algorithm, (:method, algo_method))
    tmp_algorithm = setTupleField(tmp_algorithm, (:options, merged_options))
    info = setTupleSubfield(info, :optimization, (which_algorithm, tmp_algorithm))
    return info
end

"""
    setOptimization(info::NamedTuple)

Sets up optimization-related fields in the experiment configuration.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with optimization-related fields added.

# Notes:
- Configures cost metrics, optimization parameters, algorithms, and variables to store during optimization.
- Validates the parameters to be optimized against the model structure.
"""
function setOptimization(info::NamedTuple)
    @info "  setOptimization: setting Optimization and Observation info..."
    info = setTupleField(info, (:optimization, (;)))

    # set information related to cost metrics for each variable
    info = setTupleSubfield(info, :optimization, (:model_parameter_default, info.settings.optimization.model_parameter_default))
    info = setTupleSubfield(info, :optimization, (:observational_constraints, info.settings.optimization.observational_constraints))
    info = setTupleSubfield(info,
        :optimization,
        (:multi_constraint_method, getTypeInstanceForNamedOptions(info.settings.optimization.multi_constraint_method)))

    scaling_method = isnothing(info.settings.optimization.optimization_parameter_scaling) ? "scale_none" : info.settings.optimization.optimization_parameter_scaling

    if info.settings.optimization.optimization_cost_threaded > 0 && info.settings.experiment.flags.run_optimization
        n_threads_cost = info.settings.optimization.optimization_cost_threaded > 1 ? info.settings.optimization.optimization_cost_threaded : Threads.nthreads()
        # overwrite land array type when threaded optimization is set
        info = @set info.temp.helpers.run.land_output_type = LandOutArrayMT()
        info = setTupleSubfield(info,
        :optimization,
        (:n_threads_cost, n_threads_cost))
    end

    info = setTupleSubfield(info,
        :optimization,
        (:optimization_parameter_scaling, getTypeInstanceForNamedOptions(scaling_method)))
    info = setTupleSubfield(info,
        :optimization,
        (:optimization_cost_method, getTypeInstanceForNamedOptions(info.settings.optimization.optimization_cost_method)))
        
    # check and set the list of parameters to be optimized
    info = setTupleSubfield(info, :optimization, (:model_parameters_to_optimize, info.settings.optimization.model_parameters_to_optimize))

    # set algorithm related options
    info = setAlgorithmOptions(info, :algorithm_optimization)
    info = setAlgorithmOptions(info, :algorithm_sensitivity_analysis)
    parameter_table = getOptimizationParametersTable(info.temp.models.parameter_table, info.settings.optimization.model_parameter_default, info.settings.optimization.model_parameters_to_optimize)
    
    checkOptimizedParametersInModels(info, parameter_table)

    checkParameterBounds(parameter_table.name, parameter_table.actual, parameter_table.lower, parameter_table.upper, info.optimization.optimization_parameter_scaling, show_info=true, model_names=parameter_table.model_approach)

    # get the variables to be used during optimization
    obs_vars, optim_vars, store_vars, model_vars = getConstraintNames(info.settings.optimization)
    vars_info = (;)
    vars_info = setTupleField(vars_info, (:obs, obs_vars))
    vars_info = setTupleField(vars_info, (:optimization, optim_vars))
    vars_info = setTupleField(vars_info, (:store, store_vars))
    vars_info = setTupleField(vars_info, (:model, model_vars))
    info = setTupleSubfield(info, :optimization, (:variables, (vars_info)))
    info = updateVariablesToStore(info)
    cost_options = getCostOptions(info.settings.optimization, vars_info, info.temp.output.variables, info.temp.helpers.numbers, info.temp.helpers.dates)
    info = setTupleSubfield(info, :optimization, (:cost_options, cost_options))
    info = setTupleSubfield(info, :optimization, (:parameter_table, parameter_table))
    return info
end


