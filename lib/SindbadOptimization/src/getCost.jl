export combineLoss
export loss
export lossVector

"""
    combineLoss(loss_vector::AbstractArray, ::CostSum)
    combineLoss(loss_vector::AbstractArray, ::CostMinimum)
    combineLoss(loss_vector::AbstractArray, ::CostMaximum)
    combineLoss(loss_vector::AbstractArray, percentile_value::T)

combines the loss from all constraints based on the type of combination.

# Arguments:
- `loss_vector`: a vector of losses for variables

## methods for combining the loss
- `::CostSum`: return the total sum as the cost.
- `::CostMinimum`: return the minimum of the `loss_vector` as the cost.
- `::CostMaximum`: return the maximum of the `loss_vector` as the cost.
- `percentile_value::T`: `percentile_value^th` percentile of cost of each constraint as the overall cost

"""
function combineLoss end
function combineLoss(loss_vector::AbstractArray, ::CostSum)
    return sum(loss_vector)
end

function combineLoss(loss_vector::AbstractArray, ::CostMinimum)
    return minimum(loss_vector)
end

function combineLoss(loss_vector::AbstractArray, ::CostMaximum)
    return maximum(loss_vector)
end

function combineLoss(loss_vector::AbstractArray, percentile_value::T) where {T<:Real}
    return percentile(loss_vector, percentile_value)
end


"""
    loss(param_vector::AbstractArray, base_models, forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, tbl_params, cost_options, multi_constraint_method)



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
loss

function loss(param_vector::AbstractArray, base_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method)
    updated_models = updateModelParameters(param_updater, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_timeseries, land_init, tem_info)
    loss_vector = lossVector(land_wrapper_timeseries, observations, cost_options)
    loss = combineLoss(loss_vector, multi_constraint_method)
    @debug loss_vector, loss
    return loss
end


"""
    loss(param_vector::AbstractArray, base_models, forcing, loc_forcing_t, land_init, tem_info, observations, tbl_params, cost_options, multi_constraint_method)



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
function loss(param_vector::AbstractArray, base_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info, observations, param_updater, cost_options, multi_constraint_method)
    updated_models = updateModelParameters(param_updater, base_models, param_vector)
    land_wrapper_timeseries = runTEM(updated_models, forcing, spinup_forcing, loc_forcing_t, land_init, tem_info)
    loss_vector = lossVector(land_wrapper_timeseries, observations, cost_options)
    loss = combineLoss(loss_vector, multi_constraint_method)
    @debug loss_vector, loss
    return loss
end


function loss(param_vector, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, output_array, space_output, space_land, tem_info, observations, param_updater, cost_options, multi_constraint_method)
    updated_models = updateModelParameters(param_updater, selected_models, param_vector)
    runTEM!(updated_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, space_land, tem_info)
    loss_vector = lossVector(output_array, observations, cost_options)
    loss = combineLoss(loss_vector, multi_constraint_method)
    @debug loss_vector, loss
    return loss
end


"""
    lossVector(model_output::LandWrapper, observations, cost_options)
    lossVector(model_output, observations, cost_options)
   
returns a vector of losses for variables in info.cost_options.observational_constraints   

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `model_output`: a collection of SINDBAD model output time series as a time series of stacked land NT
- `cost_options`: a table listing each observation constraint and how it should be used to calculate the loss/metric of model performance    
"""
lossVector

function lossVector(model_output, observations, cost_options)
    loss_vector = map(cost_options) do cost_option
        @debug "***cost for $(cost_option.variable)***"
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        @debug "size y, yσ, ŷ", size(y), size(yσ), size(ŷ)
        # (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ, cost_option.valids)
        metr = metric(y, yσ, ŷ, lossMetric) * cost_option.cost_weight
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        @debug "$(cost_option.variable) => $(nameof(typeof(lossMetric))): $(metr)"
        metr
    end
    @debug "\n-------------------\n"
    return loss_vector
end

function lossVector(model_output::LandWrapper, observations, cost_options)
    loss_vector = map(cost_options) do cost_option
        @debug "$(cost_option.variable)"
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        @debug "size y, yσ, ŷ", size(y), size(yσ), size(ŷ), size(idxs)
        (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ) ## cannot use the valids because LandWrapper produces vector
        metr = metric(y, yσ, ŷ, lossMetric) * cost_option.cost_weight
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        @debug "$(cost_option.variable) => $(nameof(typeof(lossMetric))): $(metr)"
        metr
    end
    @debug "\n-------------------\n"
    return loss_vector
end

