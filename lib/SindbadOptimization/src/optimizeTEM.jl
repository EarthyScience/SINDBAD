export optimizeTEM


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
    cost_function = x -> cost(x, info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.output_array, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method)

    
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


    cost_function = x -> cost(x, info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], loc_forcing_t, run_helpers.loc_land, run_helpers.tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method)

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


    cost_function = x -> cost(x, info.models.forward, run_helpers.space_forcing[1], run_helpers.space_spinup_forcing[1], run_helpers.loc_forcing_t, run_helpers.land_timeseries, run_helpers.loc_land, tem_info, observations, tbl_params, cost_options, info.optimization.multi_constraint_method)

    # run the optimizer
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, info.optimization.algorithm.options, info.optimization.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end
