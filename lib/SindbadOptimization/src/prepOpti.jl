export prepCostOptions
export prepOpti
export prepParameters

"""
    prepCostOptions(obs_array, cost_options, <:SindbadCostMethod)

remove all the variables that have less than minimum datapoints from being used in the optimization

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_options`: a table listing each observation constraint and how it should be used to calculate the loss/metric of model performance
- `::SindbadCostMethod`: a value to indicate that the cost function method
    - `CostModelObs`: a value to indicate that the cost function method is based on observation data
    - `CostModelObsPriors`: a value to indicate that the cost function method is based on observation data and priors
"""
prepCostOptions


function prepCostOptions(observations, cost_options)
    return prepCostOptions(observations, cost_options, CostModelObs())
end

function prepCostOptions(observations, cost_options, ::CostModelObsPriors)
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


"""
    prepOpti(forcing, observations, info)

Prepares optimization parameters and settings based on provided inputs.

# Arguments
- `forcing`: Input forcing data for the optimization
- `observations`: Observed data used for comparison/calibration
- `info`: Additional information and settings for optimization setup
- `optimization_cost_method`: Method for calculating the cost function

# Returns
Configuration parameters and settings for optimization

# Description
This function processes the input data and configuration to set up the optimization
problem. It handles the preparation of parameters and settings required for the
optimization process.
"""
prepOpti

function prepOpti(forcing, observations, info)
    return prepOpti(forcing, observations, info, CostModelObs())
end

function  prepOpti(forcing, observations, info, optimization_cost_method)
    run_helpers = prepTEM(forcing, info)

    param_helpers = prepParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution, info.optimization.optimization_parameter_scaling)
    
    tbl_params = param_helpers.tbl_params
    default_values = param_helpers.default_values
    lower_bounds = param_helpers.lower_bounds
    upper_bounds = param_helpers.upper_bounds

    cost_options = prepCostOptions(observations, info.optimization.cost_options, optimization_cost_method)

    # param_model_id_val = info.optimization.param_model_id_val
    cost_function = x -> cost(x, default_values, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method, info.optimization.optimization_parameter_scaling, optimization_cost_method)

    opti_helpers = (; tbl_params=tbl_params, cost_function=cost_function, default_values=default_values, lower_bounds=lower_bounds, upper_bounds=upper_bounds)
    
    return opti_helpers
end


"""
    prepParameters(selected_models, model_parameter_default, model_parameters_to_optimize, num_type, temporal_resolution, optimization_parameter_scaling)

Prepare model parameters for optimization by processing default parameters and parameters to be optimized.

# Arguments
- `selected_models`: Collection of models selected for parameter optimization
- `model_parameter_default`: Default parameter values for the models
- `model_parameters_to_optimize`: Parameters that will be optimized
- `num_type`: Numerical type to be used (e.g., Float64)
- `temporal_resolution`: Time resolution for the model parameters
- `optimization_parameter_scaling`: Scaling method/type for parameter optimization

# Returns
A tuple containing processed parameters ready for optimization
"""
function prepParameters(selected_models, model_parameter_default, model_parameters_to_optimize, num_type, temporal_resolution, parameter_scaling)
    tbl_params = getParameters(selected_models, model_parameter_default, model_parameters_to_optimize, num_type, temporal_resolution)
    
    default_values, lower_bounds, upper_bounds = scaleParameters(tbl_params, parameter_scaling)

    param_helpers = (; tbl_params=tbl_params, default_values=default_values, lower_bounds=lower_bounds, upper_bounds=upper_bounds)
    return param_helpers
end