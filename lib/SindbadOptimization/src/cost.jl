export cost
export costYax

"""
    costYax(param_vector::AbstractArray, selected_models, forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `selected_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `forcing`: a forcing NT that contains the forcing time series set for a given location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_timeseries`: a timeseries of preallocated vector with one time step  output land as the element
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/cost
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the cost/metric of model performance
- `multi_constraint_method`: a method determining how the vector of costes should/not be combined to produce the cost number or vector as required by the selected optimization algorithm
"""
costYax

function costYax(param_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info)
    cost_vector = metricVector(land_wrapper_timeseries, observations, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    @debug cost_vector, cost_metric
    return cost
end

function costYax(param_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info)
    cost_vector = metricVector(land_wrapper_timeseries, observations, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    @debug cost_vector, cost_metric
    return cost_metric
end


"""
    cost(param_vector, default_values, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, <:SindbadCostMethod)

Calculate the cost for a parameter vector.

# Arguments
- `param_vector`: Vector of parameter values to be optimized
- 'default_values': Default values for model parameters
- `selected_models`: Collection of selected models for simulation
- `space_forcing`: Forcing data for the main simulation period
- `space_spinup_forcing`: Forcing data for the spin-up period
- `loc_forcing_t`: Time-specific forcing data
- `output_array`: Array to store simulation outputs
- `space_output`: Spatial output configuration
- `space_land`: Land surface characteristics
- `tem_info`: Temporal information for simulation
- `observations`: Observed data for comparison
- `param_updater`: Function to update parameters
- `cost_options`: Options for cost function calculation
- `multi_constraint_method`: Method for handling multiple constraints
- `parameter_scaling_type`: Type of parameter scaling
-  <:SindbadCostMethod: a type parameter indicating cost calculation method
    - `::CostModelObs`: Type parameter indicating cost calculation between model and observations
    - `::CostModelObsPriors`: Type parameter indicating cost calculation between model, observations, and priors. NOTE THAT THIS METHOD IS JUST A PLACEHOLDER AND DOES NOT CALCULATE PRIOR COST PROPERLY YET.

# Returns
Cost value representing the difference between model outputs and observations

# Description
Computes the cost function by comparing model simulation results with observational data,
considering various spatial and temporal configurations, parameter scaling, and multiple constraint methods.
"""
cost

function cost(param_vector, default_values, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, ::CostModelObs)
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    runTEM!(updated_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info)
    cost_vector = metricVector(output_array, observations, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    @debug cost_vector, cost_metric
    return cost_metric
end


function cost(param_vector, default_values, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, ::CostModelObsPriors)
    # prior has to be calculated before the parameters are backscaled and models are updated
    cost_prior = metric(param_vector, param_vector, default_values, MSE())
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    runTEM!(updated_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info)
    cost_vector = metricVector(output_array, observations, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    cost_metric = cost_metric + cost_prior
    @debug cost_vector, cost_metric
    return cost_metric
end

function cost(param_vector, default_values, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    cost_metric = cost(param_vector, default_values, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, CostModelObs())
    return cost_metric
end

