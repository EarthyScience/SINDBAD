export prepCostOptions
export prepOpti

"""
    prepCostOptions(obs_array, cost_options)

remove all the variables that have less than minimum datapoints from being used in the optimization

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_options`: a table listing each observation constraint and how it should be used to calculate the loss/metric of model performance
"""
prepCostOptions


function prepCostOptions(observations, cost_options)
    return prepCostOptions(observations, cost_options, CostModelObs())
end

function prepCostOptions(observations, cost_options, ::CostModelObs)
    valids=[]
    is_valid = []
    vars = cost_options.variable
    obs_inds = cost_options.obs_ind
    min_data_points = cost_options.min_data_points
    for vi in eachindex(vars)
        obs_ind_start = obs_inds[vi]
        min_point = min_data_points[vi]
        y = observations[obs_ind_start]
        yσ = observations[obs_ind_start+1]
        idxs = Array(.!isInvalid.(y .* yσ))
        total_point = sum(idxs)
        if total_point < min_point
            push!(is_valid, false)
        else
            push!(is_valid, true)
        end
        push!(valids, idxs)
    end
    cost_options = setTupleField(cost_options, (:valids, valids))
    cost_options = setTupleField(cost_options, (:is_valid, is_valid))
    cost_options = dropFields(cost_options, (:min_data_points, :temporal_data_aggr, :aggr_func,))
    cost_option_table = Table(cost_options)
    cost_options_table_filtered = filter(row -> row.is_valid === true , cost_option_table)
    return cost_options_table_filtered
end


function  prepOpti(forcing, observations, info)
    run_helpers = prepTEM(forcing, info)

    tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution)

    # get the default and bounds

    default_values, lower_bounds, upper_bounds = scaleParameters(tbl_params, info.optimization.optimization_parameter_scaling)

    cost_options = prepCostOptions(observations, info.optimization.cost_options)

    # param_model_id_val = info.optimization.param_model_id_val
    cost_function = x -> cost(x, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method, info.optimization.optimization_parameter_scaling, info.optimization.optimization_cost_method)
    opti_helpers = (; tbl_params=tbl_params, cost_function=cost_function, default_values=default_values, lower_bounds=lower_bounds, upper_bounds=upper_bounds)
    return opti_helpers
end