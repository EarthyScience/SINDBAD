export optimizeTEM
export getLoss

"""
    getLoss(param_vector::AbstractArray, base_models, forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `forcing`: a forcing NT that contains the forcing time series set for a given location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_timeseries`: a timeseries of preallocated vector with one time step  output land as the element
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(param_vector::AbstractArray, base_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method)
    updated_models = updateModelParameters(param_updater, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info)
    loss_vector = getLossVector(land_wrapper_timeseries, observations, cost_options)
    loss = combineLoss(loss_vector, multi_constraint_method)
    @debug loss_vector, loss
    return loss
end


"""
    getLoss(param_vector::AbstractArray, base_models, forcing, loc_forcing_t, land_init, tem_info, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `forcing`: a forcing NT that contains the forcing time series set for a given location
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(param_vector::AbstractArray, base_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method)
    updated_models = updateModelParameters(param_updater, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info)
    loss_vector = getLossVector(land_wrapper_timeseries, observations, cost_options)
    loss = combineLoss(loss_vector, multi_constraint_method)
    @debug loss_vector, loss
    return loss
end


"""
    getLoss(param_vector::AbstractArray, base_models, forcing_nt_array, space_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `space_forcing`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `loc_forcing_t`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `space_output`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `space_land`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `tem_info`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(param_vector, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method)
    updated_models = updateModelParameters(param_updater, selected_models, param_vector)
    runTEM!(updated_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info)
    loss_vector = getLossVector(output_array, observations, cost_options)
    loss = combineLoss(loss_vector, multi_constraint_method)
    @debug loss_vector, loss
    return loss
end


"""
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, ::LandOutArray || ::LandOutArray || ::LandOutTimeseries)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `::LandOutArray` || `::LandOutArray` || `::LandOutTimeseries`:
    - `LandOutArray`: a value to indicate that the time loop of the model will output the land as an array when runTEM is called
    - `LandOutStacked`: a value to indicate that the time loop of the model will stack the land as a time series when runTEM is called
    - `LandOutTimeseries:` a value to indicate that the time loop of the model will output the land as an array when runTEM is called
"""
optimizeTEM

function optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, ::LandOutArray)
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution)

    param_to_index = getParameterIndices(info.models.forward, tbl_params);
    
    # get the default and bounds
    default_values = tbl_params.default
    lower_bounds = tbl_params.lower
    upper_bounds = tbl_params.upper

    run_helpers = prepTEM(forcing, info)

    cost_options = prepCostOptions(observations, info.optimization.cost_options)

    # param_model_id_val = info.optimization.param_model_id_val
    cost_function = x -> getLoss(x, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method)

    
    # run the optimizer
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, info.optimization.algorithm.options, info.optimization.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end

function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::LandOutStacked)

    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution)

    cost_options = prepCostOptions(observations, info.optimization.cost_options)

    # get the default and bounds
    default_values = tbl_params.default
    lower_bounds = tbl_params.lower
    upper_bounds = tbl_params.upper

    run_helpers = prepTEM(forcing, info)


    cost_function = x -> getLoss(x, info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], loc_forcing_t, run_helpers.loc_land, run_helpers.tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method)

    # run the optimizer
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, info.optimization.algorithm.options, info.optimization.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end

function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::LandOutTimeseries)

    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize,
        info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution)

    cost_options = prepCostOptions(observations, info.optimization.cost_options)

    # get the default and bounds
    default_values = tbl_params.default
    lower_bounds = tbl_params.lower
    upper_bounds = tbl_params.upper

    run_helpers = prepTEM(forcing, info)


    cost_function = x -> getLoss(x, info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, run_helpers.land_timeseries, run_helpers.loc_land, tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method)

    # run the optimizer
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, info.optimization.algorithm.options, info.optimization.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end
