export cost
export costLand


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

function cost(param_vector, _, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type, ::CostModelObs)
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


"""
    costLand(param_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    
    costLand(param_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, _, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)

Calculates the cost of SINDBAD model simulations for a single location by comparing model outputs as collections of SINDBAD `land` with observations using specified metrics and constraints.

In the first variant, the land_time_series is preallocated for computational efficiency. In the second variant, the runTEM stacks the land using map function and the preallocations is not necessary.

# Arguments:
- `param_vector::AbstractArray`: A vector of model parameter values to be optimized.
- `selected_models`: A tuple of selected SINDBAD models in the given model structure, the parameters of which are optimized.
- `forcing`: A forcing NamedTuple containing the time series of environmental drivers for the simulation.
- `spinup_forcing`: A forcing NamedTuple for the spinup phase, used to initialize the model to a steady state.
- `loc_forcing_t`: A forcing NamedTuple for a single location and a single time step.
- `land_timeseries`: A preallocated vector to store the land state for each time step during the simulation.
- `land_init`: The initial SINDBAD land NamedTuple containing all fields and subfields.
- `tem_info`: A nested NamedTuple containing necessary information for running SINDBAD TEM, including helpers, models, and spinup configurations.
- `observations`: A NamedTuple or vector of arrays containing observational data, uncertainties, and masks for calculating performance metrics.
- `param_updater`: A function to update model parameters based on the `param_vector`.
- `cost_options`: A table specifying how each observation constraint should be used to calculate the cost or performance metric.
- `multi_constraint_method`: A method for combining the vector of costs into a single cost value or vector, as required by the optimization algorithm.
- `parameter_scaling_type`: Specifies the type of scaling applied to the parameters during optimization.

# Returns:
- `cost_metric`: A scalar or vector representing the cost, calculated by comparing model outputs with observations using the specified metrics and constraints.

# Notes:
- The function updates the selected models using the `param_vector` and `param_updater`.
- It runs the SINDBAD TEM simulation for the specified location using `runTEM`.
- The model outputs are compared with observations using `metricVector`, which calculates the performance metrics.
- The resulting cost vector is combined into a single cost value or vector using `combineMetric` and the specified `multi_constraint_method`.

# Examples:
1. **Calculating cost for a single location**:
    ```julia
    cost = costLand(param_vector, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    ```

2. **Using a custom multi-constraint method**:
    ```julia
    custom_method = CustomConstraintMethod()
    cost = costLand(param_vector, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, custom_method, parameter_scaling_type)
    ```

3. **Handling observational uncertainties**:
    - Observations can include uncertainties and masks to refine the cost calculation, ensuring robust model evaluation.

"""
costLand

function costLand(param_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info)
    cost_vector = metricVector(land_wrapper_timeseries, observations, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    @debug cost_vector, cost_metric
    return cost_metric
end

function costLand(param_vector::AbstractArray, selected_models, forcing, spinup_forcing, loc_forcing_t, ::Nothing, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method, parameter_scaling_type)
    updated_models = updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info)
    cost_vector = metricVector(land_wrapper_timeseries, observations, cost_options)
    cost_metric = combineMetric(cost_vector, multi_constraint_method)
    @debug cost_vector, cost_metric
    return cost_metric
end