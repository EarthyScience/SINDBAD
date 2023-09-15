export optimizeTEM
export getLoss

"""
    getLoss(param_vector::AbstractArray, base_models, forcing, forcing_one_timestep, land_timeseries, land_init, tem, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `forcing`: a forcing NT that contains the forcing time series set for a given location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_timeseries`: a timeseries of preallocated vector with one time step  output land as the element
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector::AbstractArray,
    base_models,
    forcing,
    spinup_forcing,
    forcing_one_timestep,
    land_timeseries,
    land_init,
    tem,
    observations,
    tbl_params,
    cost_options,
    multi_constraint_method)
    updated_models = updateModelParameters(tbl_params, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, forcing_one_timestep, land_timeseries, land_init, tem)
    loss_vector = getLossVector(observations, land_wrapper_timeseries, cost_options)
    @debug loss_vector
    return combineLoss(loss_vector, multi_constraint_method)
end


"""
    getLoss(param_vector::AbstractArray, base_models, forcing, forcing_one_timestep, land_init, tem, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `forcing`: a forcing NT that contains the forcing time series set for a given location
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector::AbstractArray,
    base_models,
    forcing,
    spinup_forcing,
    forcing_one_timestep,
    land_init,
    tem,
    observations,
    tbl_params,
    cost_options,
    multi_constraint_method)
    updated_models = updateModelParameters(tbl_params, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, forcing_one_timestep, land_init, tem)
    loss_vector = getLossVector(observations, land_wrapper_timeseries, cost_options)
    return combineLoss(loss_vector, multi_constraint_method)
end

"""
    getLoss(param_vector::AbstractArray, base_models, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, tem, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `loc_forcings`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_outputs`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `land_init_space`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector,
    selected_models,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    tem,
    observations,
    tbl_params,
    cost_options,
    multi_constraint_method)
    updated_models = updateModelParameters(tbl_params, selected_models, param_vector)
    runTEM!(updated_models,
        loc_forcings,
        loc_spinup_forcings,
        forcing_one_timestep,
        loc_outputs,
        land_init_space,
        tem)
    loss_vector = getLossVector(observations, output_array, cost_options)
    return combineLoss(loss_vector, multi_constraint_method)
end



"""
    getLoss(param_vector::AbstractArray, base_models, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, tem, observations, tbl_params, cost_options, multi_constraint_method)



# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `loc_forcings`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_outputs`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `land_init_space`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multi_constraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector,
    selected_models,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    tem,
    observations,
    param_model_id_val,
    p_type,
    cost_options,
    multi_constraint_method)
    # @show param_vector
    param_vector = p_type(param_vector)
    # param_vector = param_vector)
    selected_models = updateModelParameters(selected_models, param_vector, param_model_id_val)
    runTEM!(selected_models,
        loc_forcings,
        loc_spinup_forcings,
        forcing_one_timestep,
        loc_outputs,
        land_init_space,
        tem)
    loss_vector = getLossVector(observations, output_array, cost_options)
    return combineLoss(loss_vector, multi_constraint_method)
end


"""
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, ::LandOutArray)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `::LandOutArray`: DESCRIPTION
"""
function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::LandOutArray)

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = getParameters(tem.models.forward,
        optim.model_parameter_default,
        optim.model_parameters_to_optimize,
        tem.helpers.numbers.sNT)

    cost_options = prepCostOptions(observations, optim.cost_options)

    # get the default and bounds
    default_values = tbl_params.default
    lower_bounds = tbl_params.lower
    upper_bounds = tbl_params.upper

    run_helpers = prepTEM(forcing, info)
    param_model_id_val = info.optim.param_model_id_val
    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            run_helpers.loc_forcings,
            run_helpers.loc_spinup_forcings,
            run_helpers.forcing_one_timestep,
            run_helpers.output_array,
            run_helpers.loc_outputs,
            run_helpers.land_init_space,
            run_helpers.tem_with_types,
            observations,
            tbl_params,
            cost_options,
            optim.multi_constraint_method)
            # cost_function =
            # x -> getLoss(x,
            #     tem.models.forward,
            #     run_helpers.loc_forcings,
            #     run_helpers.loc_spinup_forcings,
            #     run_helpers.forcing_one_timestep,
            #     run_helpers.output_array,
            #     run_helpers.loc_outputs,
            #     run_helpers.land_init_space,
            #     run_helpers.tem_with_types,
            #     observations,
            #     param_model_id_val,
            #     typeof(default_values),
            #     cost_options,
            #     optim.multi_constraint_method)
    
    # run the optimizer
    optim_para = optimizer(cost_function,
        default_values,
        lower_bounds,
        upper_bounds,
        optim.algorithm.options,
        optim.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end


"""
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, ::LandOutStacked)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `::LandOutStacked`: a value to indicate that the time loop of the model will stack the land as a time series when runTEM is called
"""
function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::LandOutStacked)

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = getParameters(tem.models.forward,
        optim.model_parameter_default,
        optim.model_parameters_to_optimize,
        tem.helpers.numbers.sNT)

    cost_options = prepCostOptions(observations, optim.cost_options)

    # get the default and bounds
    default_values = tbl_params.default
    lower_bounds = tbl_params.lower
    upper_bounds = tbl_params.upper

    run_helpers = prepTEM(forcing, info)


    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            run_helpers.loc_forcings[1],
            run_helpers.loc_spinup_forcings[1],
            forcing_one_timestep,
            run_helpers.land_one,
            tem_with_types,
            observations,
            tbl_params,
            cost_options,
            optim.multi_constraint_method)

    # run the optimizer
    optim_para = optimizer(cost_function,
        default_values,
        lower_bounds,
        upper_bounds,
        optim.algorithm.options,
        optim.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end


"""
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, ::LandOutTimeseries)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `::LandOutTimeseries`: DESCRIPTION
"""
function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::LandOutTimeseries)

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = getParameters(tem.models.forward,
        optim.model_parameter_default,
        optim.model_parameters_to_optimize,
        tem.helpers.numbers.sNT)

    cost_options = prepCostOptions(observations, optim.cost_options)

    # get the default and bounds
    default_values = tbl_params.default
    lower_bounds = tbl_params.lower
    upper_bounds = tbl_params.upper

    run_helpers = prepTEM(forcing, info)


    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            run_helpers.loc_forcings[1],
            run_helpers.loc_spinup_forcings[1],
            run_helpers.forcing_one_timestep,
            run_helpers.land_timeseries,
            run_helpers.land_one,
            tem_with_types,
            observations,
            tbl_params,
            cost_options,
            optim.multi_constraint_method)

    # run the optimizer
    optim_para = optimizer(cost_function,
        default_values,
        lower_bounds,
        upper_bounds,
        optim.algorithm.options,
        optim.algorithm.method)

    # update the parameter table with the optimized values
    tbl_params.optim .= optim_para
    return tbl_params
end
