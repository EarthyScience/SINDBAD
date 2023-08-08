export combineLoss
export filterCommonNaN
export filterConstraintMinimumDatapoints
export getData
export getLocObs!
export getLoss
export getLossVector
export getModelOutputView
export optimizeTEM

"""
    aggregateData(dat, cost_option, nothing::Val{:timespace})

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `cost_option`: information for a observation constraint on how it should be used to calcuate the loss/metric of model performance
- `nothing`: DESCRIPTION
"""
function aggregateData(dat, cost_option, ::Val{:timespace})
    dat = temporalAggregation(dat, cost_option.temporal_aggregator, cost_option.temporal_aggr_type)
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_aggr)
    return dat
end

"""
    aggregateData(dat, cost_option, nothing::Val{:spacetime})

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `cost_option`: information for a observation constraint on how it should be used to calcuate the loss/metric of model performance
- `nothing`: DESCRIPTION
"""
function aggregateData(dat, cost_option, ::Val{:spacetime})
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_aggr)
    dat = temporalAggregation(dat, cost_option.temporal_aggregator, cost_option.temporal_aggr_type)
    return dat
end

"""
    combineLoss(loss_vector::AbstractArray, nothing::Val{:sum})

return the total of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::Val{:sum})
    return sum(loss_vector)
end


"""
    combineLoss(loss_vector::AbstractArray, nothing::Val{:minimum})

return the minimum of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::Val{:minimum})
    return minimum(loss_vector)
end

"""
    combineLoss(loss_vector::AbstractArray, nothing::Val{:maximum})

return the maximum of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::Val{:maximum})
    return maximum(loss_vector)
end


"""
    combineLoss(loss_vector::AbstractArray, percentile_value::T)

return the percentile_value^th percentile of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, percentile_value::T) where {T<:Real}
    return percentile(loss_vector, percentile_value)
end

"""
    filterCommonNaN(y, yσ, ŷ)

return model and obs data filtering for the common nan

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
"""
function filterCommonNaN(y, yσ, ŷ)
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return y[idxs], yσ[idxs], ŷ[idxs]
end


"""
    filterConstraintMinimumDatapoints(obs_array, cost_options)

remove all the variables that have less than minimum datapoints from being used in the optimization

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
"""
function filterConstraintMinimumDatapoints(observations, cost_options)
    cost_options_filtered = cost_options
    foreach(cost_options) do cost_option
        obs_ind_start = cost_option.obs_ind
        min_points = cost_option.min_data_points
        var_name = cost_option.variable
        y = observations[obs_ind_start]
        yσ = observations[obs_ind_start+1]
        idxs = (.!isnan.(y .* yσ))
        total_points = sum(idxs)
        if total_points < min_points
            cost_options_filtered = filter(row -> row.variable !== var_name, cost_options_filtered)
            @warn "$(cost_option.variable) => $(total_points) available data points < $(min_points) minimum points. Removing the constraint."
        end
    end
    return cost_options_filtered
end

"""
    getData(model_output::landWrapper, observations, cost_option)

DOCSTRING

# Arguments:
- `model_output`: a collection of SINDBAD model output time series as a time series of stacked land NT
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_option`: information for a observation constraint on how it should be used to calcuate the loss/metric of model performance
"""
function getData(model_output::landWrapper, observations, cost_option)
    obs_ind = cost_option.obs_ind
    mod_field = cost_option.mod_field
    mod_subfield = cost_option.mod_subfield
    ŷField = getproperty(model_output, mod_field)
    ŷ = getproperty(ŷField, mod_subfield)
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
        y = y[:]
        yσ = yσ[:]
    end
    # @show size(ŷ), size(y), size(yσ)
    # @show typeof(ŷ), typeof(y), typeof(yσ)
    # ymask = observations[obs_ind + 2]

    ŷ = aggregateData(ŷ, cost_option, cost_option.aggr_order)

    if cost_option.temporal_aggr_obs
        y = aggregateData(y, cost_option, cost_option.aggr_order)
        yσ = aggregateData(yσ, cost_option, cost_option.aggr_order)
    end
    return (y, yσ, ŷ)
end

"""
    getData(model_output::AbstractArray, observations, cost_option)

DOCSTRING

# Arguments:
- `model_output`: a collection of SINDBAD model output time series as a preallocated array
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_option`: information for a observation constraint on how it should be used to calcuate the loss/metric of model performance
"""
function getData(model_output::AbstractArray, observations, cost_option)
    obs_ind = cost_option.obs_ind
    ŷ = model_output[cost_option.mod_ind]
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
    end
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]
    # ymask = observations[obs_ind + 2]

    ŷ = aggregateData(ŷ, cost_option, cost_option.aggr_order)

    if cost_option.temporal_aggr_obs
        y = aggregateData(y, cost_option, cost_option.aggr_order)
        yσ = aggregateData(yσ, cost_option, cost_option.aggr_order)
    end
    return (y, yσ, ŷ)
end

"""
    getLocObs!(obs_array, nothing::Val{obs_vars}, nothing::Val{s_names}, loc_obs, s_locs)

DOCSTRING

# Arguments:
- `obs_array`: an array of all observation variables for all locations
- `loc_obs`: a NT of observations for a given location to be used as reference to overwrite using @set
- `s_locs`: name and values of the location/space dimensions
- `Val{obs_vars}`: a Val dispatch to generate the code based on the list of observation variables
- `Val{s_names}`: a Val dispatch to generate the code based on names the location/space dimensions
"""
@generated function getLocObs!(
    obs_array,
    loc_obs,
    s_locs,
    ::Val{obs_vars},
    ::Val{s_names}) where {obs_vars,s_names}
    output = quote end
    foreach(obs_vars) do obsv
        push!(output.args, Expr(:(=), :d, Expr(:., :obs_array, QuoteNode(obsv))))
        s_ind = 1
        foreach(s_names) do s_name
            expr = Expr(:(=),
                :d,
                Expr(:call,
                    :view,
                    Expr(:parameters,
                        Expr(:call, :(=>), QuoteNode(s_name), Expr(:ref, :s_locs, s_ind))),
                    :d))
            push!(output.args, expr)
            return s_ind += 1
        end
        return push!(output.args,
            Expr(:(=),
                :loc_obs,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :loc_obs, QuoteNode(obsv)), :d)))) #= none:1 =#
    end
    return output
end

"""
    getLoss(param_vector::AbstractArray, base_models, forcing, forcing_one_timestep, land_timeseries, land_init, tem, observations, tbl_params, cost_options, multiconstraint_method)

DOCSTRING

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
- `multiconstraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector::AbstractArray,
    base_models,
    forcing,
    forcing_one_timestep,
    land_timeseries,
    land_init,
    tem,
    observations,
    tbl_params,
    cost_options,
    multiconstraint_method)
    updated_models = updateModelParameters(tbl_params, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, forcing_one_timestep, land_timeseries, land_init, tem)
    loss_vector = getLossVector(observations, land_wrapper_timeseries, cost_options)
    @debug loss_vector
    return combineLoss(loss_vector, multiconstraint_method)
end


"""
    getLoss(param_vector::AbstractArray, base_models, forcing, forcing_one_timestep, land_init, tem, observations, tbl_params, cost_options, multiconstraint_method)

DOCSTRING

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
- `multiconstraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector::AbstractArray,
    base_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem,
    observations,
    tbl_params,
    cost_options,
    multiconstraint_method)
    updated_models = updateModelParameters(tbl_params, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, forcing_one_timestep, land_init, tem)
    loss_vector = getLossVector(observations, land_wrapper_timeseries, cost_options)
    return combineLoss(loss_vector, multiconstraint_method)
end

"""
    getLoss(param_vector::AbstractArray, base_models, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem, observations, tbl_params, cost_options, multiconstraint_method)

DOCSTRING

# Arguments:
- `param_vector`: a vector of model parameter values, with the size of model_parameters_to_optimize, to run the TEM.
- `base_models`: a Tuple of selected SINDBAD models in the given model structure, the parameter(s) of which are optimized
- `forcing_nt_array`: a forcing NT that contains the forcing time series set for ALL locations, with each variable as an instantiated array in memory
- `loc_forcings`: a collection of copies of forcings for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `output_array`: an output array/view for ALL locations
- `loc_outputs`: a collection of copies of outputs for several locations that are replicated for the number of threads. A safety feature against data race, that ensures that each thread only accesses one object at any given moment
- `land_init_space`: a collection of initial SINDBAD land for each location. This (rather inefficient) approach is necessary to ensure that the subsequent locations do not overwrite the model pools and states (arrays) of preceding lcoations
- `loc_space_inds`: a collection of spatial indices/pairs of indices used to loop through space in parallelization
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
- `multiconstraint_method`: a method determining how the vector of losses should/not be combined to produce the loss number or vector as required by the selected optimization algorithm
"""
function getLoss(
    param_vector::AbstractArray,
    base_models,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem,
    observations,
    tbl_params,
    cost_options,
    multiconstraint_method)
    updated_models = updateModelParameters(tbl_params, base_models, param_vector)
    runTEM!(updated_models,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem)
    loss_vector = getLossVector(observations, output_array, cost_options)
    return combineLoss(loss_vector, multiconstraint_method)
end

"""
    getLossVector(observations, model_output, cost_options)

returns a vector of losses for variables in info.cost_options.observational_constraints

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `model_output`: a collection of SINDBAD model output time series, either as a preallocated array or as a time series of stacked land NT
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
"""
function getLossVector(observations, model_output, cost_options)
    loss_vector = map(cost_options) do cost_option
        @debug "$(cost_option.variable)"
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        @debug "size y, yσ, ŷ", size(y), size(yσ), size(ŷ)
        (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ)
        # @debug @time metr = loss(y, yσ, ŷ, lossMetric)
        metr = loss(y, yσ, ŷ, lossMetric)
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        # @info "$(cost_option.variable) => $(valToSymbol(lossMetric)): $(metr)"
        metr
    end
    # println("-------------------")
    return loss_vector
end


"""
    getModelOutputView(mod_dat)

DOCSTRING
"""
function getModelOutputView(mod_dat)
    return mod_dat[:]
end

"""
    getModelOutputView(mod_dat::AbstractArray{T, 2})

DOCSTRING
"""
function getModelOutputView(mod_dat::AbstractArray{T,2}) where {T}
    return @view mod_dat[:, 1]
end

"""
    getModelOutputView(mod_dat::AbstractArray{T, 3})

DOCSTRING
"""
function getModelOutputView(mod_dat::AbstractArray{T,3}) where {T}
    return @view mod_dat[:, 1, :]
end

"""
    getModelOutputView(mod_dat::AbstractArray{T, 4})

DOCSTRING
"""
function getModelOutputView(mod_dat::AbstractArray{T,4}) where {T}
    return @view mod_dat[:, 1, :, :]
end

"""
    spatialAggregation(dat, _, nothing::Val{:cat})

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `_`: unused argument
- `nothing`: DESCRIPTION
"""
function spatialAggregation(dat, _, ::Val{:cat})
    return dat
end

"""
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, nothing::Val{:array})

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `nothing`: DESCRIPTION
"""
function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::Val{:array})

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = Sindbad.getParameters(tem.models.forward,
        optim.model_parameter_default,
        optim.model_parameters_to_optimize)

    cost_options = filterConstraintMinimumDatapoints(observations, optim.cost_options)

    # get the default and bounds
    default_values = tem.helpers.numbers.sNT.(tbl_params.default)
    lower_bounds = tem.helpers.numbers.sNT.(tbl_params.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tbl_params.upper)

    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, _, _, tem_with_vals = prepTEM(forcing, info)

    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            forcing_nt_array,
            loc_forcings,
            forcing_one_timestep,
            output_array,
            loc_outputs,
            land_init_space,
            loc_space_inds,
            tem_with_vals,
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
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, nothing::Val{:land_stacked})

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `Val{:land_stacked}`: a value to indicate that the time loop of the model will stack the land as a time series when runTEM is called
"""
function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::Val{:land_stacked})

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = Sindbad.getParameters(tem.models.forward,
        optim.model_parameter_default,
        optim.model_parameters_to_optimize)

    cost_options = filterConstraintMinimumDatapoints(observations, optim.cost_options)

    # get the default and bounds
    default_values = tem.helpers.numbers.sNT.(tbl_params.default)
    lower_bounds = tem.helpers.numbers.sNT.(tbl_params.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tbl_params.upper)

    _, loc_forcings, forcing_one_timestep, _, loc_outputs, land_init_space, _, _, _, tem_with_vals = prepTEM(forcing, info)


    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            loc_forcings[1],
            forcing_one_timestep,
            land_init_space[1],
            tem_with_vals,
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
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple, nothing::Val{:land_timeseries})

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `nothing`: DESCRIPTION
"""
function optimizeTEM(forcing::NamedTuple,
    observations,
    info::NamedTuple,
    ::Val{:land_timeseries})

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = Sindbad.getParameters(tem.models.forward,
        optim.model_parameter_default,
        optim.model_parameters_to_optimize)

    cost_options = filterConstraintMinimumDatapoints(observations, optim.cost_options)

    # get the default and bounds
    default_values = tem.helpers.numbers.sNT.(tbl_params.default)
    lower_bounds = tem.helpers.numbers.sNT.(tbl_params.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tbl_params.upper)

    _, loc_forcings, forcing_one_timestep, _, loc_outputs, land_init_space, _, _, _, tem_with_vals = prepTEM(forcing, info)

    land_timeseries = Vector{typeof(land_init_space[1])}(undef, info.tem.helpers.dates.size)

    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            loc_forcings[1],
            forcing_one_timestep,
            land_timeseries,
            land_init_space[1],
            tem_with_vals,
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
