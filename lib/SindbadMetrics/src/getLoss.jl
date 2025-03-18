export combineLoss
export filterCommonNaN
export getData
export lossVector
export getModelOutputView

"""
    aggregateData(dat, cost_option, ::TimeSpace)
    aggregateData(dat, cost_option, ::SpaceTime)

aggregate the data based on the order of aggregation.

# Arguments:
- `dat`: a data array/vector to aggregate
- `cost_option`: information for a observation constraint on how it should be used to calculate the loss/metric of model performance
- `::TimeSpace`: appropriate type dispatch for the order of aggregation
- `::SpaceTime`: appropriate type dispatch for the order of aggregation
"""
aggregateData

function aggregateData(dat, cost_option, ::TimeSpace)
    @debug "aggregating data", size(dat)
    dat = temporalAggregation(dat, cost_option.temporal_aggr, cost_option.temporal_aggr_type)
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_data_aggr)
    return dat
end

function aggregateData(dat, cost_option, ::SpaceTime)
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_data_aggr)
    dat = temporalAggregation(dat, cost_option.temporal_aggr, cost_option.temporal_aggr_type)
    return dat
end


"""
    aggregateObsData(y, yσ, cost_option, ::DoAggrObs)
    aggregateObsData(y, yσ, _, ::DoNotAggrObs)

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `cost_option`: information for a observation constraint on how it should be used to calculate the loss/metric of model performance
- `::DoAggrObs`: appropriate type dispatch for aggregation of observation data
- `::DoNotAggrObs`: appropriate type dispatch for not aggregating observation data
"""
aggregateObsData

function aggregateObsData(y, cost_option, ::DoAggrObs)
    y = aggregateData(y, cost_option, cost_option.aggr_order)
    return y
end

function aggregateObsData(y, _, ::DoNotAggrObs)
    return y
end


"""
    applySpatialWeight(y, yσ, ŷ, cost_option, ::DoSpatialWeight)
    applySpatialWeight(y, yσ, ŷ, _, ::DoNotSpatialWeight)

return model and obs data after applying the area weight.

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::DoSpatialWeight`: type dispatch for doing area weight
- `::DoNotSpatialWeight`: type dispatch for not doing area weight
"""
applySpatialWeight

function applySpatialWeight(y, yσ, ŷ, cost_option, ::DoSpatialWeight)
    yweight = observations[cost_option.obs_ind+3]
    y .= y .* yweight
    yσ .= yσ .* yweight
    ŷ .= ŷ .* yweight
    return y, yσ, ŷ
end

function applySpatialWeight(y, yσ, ŷ, _, ::DoNotSpatialWeight)
    return y, yσ, ŷ
end

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
    filterCommonNaN(y, yσ, ŷ, idxs)
    filterCommonNaN(y, yσ, ŷ)

return model and obs data filtering for the common `NaN`.

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `idxs`: indices of valid data points    
"""
filterCommonNaN

function filterCommonNaN(y, yσ, ŷ, idxs)
    return y[idxs], yσ[idxs], ŷ[idxs]
end

function filterCommonNaN(y, yσ, ŷ)
    @debug sum(isInvalid.(y)), sum(isInvalid.(yσ)), sum(isInvalid.(ŷ))
    idxs = (.!isnan.(y .* yσ .* ŷ)) # TODO this has to be run because LandWrapper produces a vector. So, dispatch with the inefficient versions without idxs argument
    return y[idxs], yσ[idxs], ŷ[idxs]
end


function filterInvalids(ŷ, idxs)
    ŷ[.!idxs] .= eltype(ŷ)(NaN)
    return ŷ
end

function getHarmonizedData(y, yσ, ŷ, cost_option)
    
    # ŷ = filterInvalids(ŷ, cost_option.valids)
    ŷ = aggregateData(ŷ, cost_option, cost_option.aggr_order)
    y = aggregateObsData(y, cost_option, cost_option.aggr_obs)
    yσ = aggregateObsData(yσ, cost_option, cost_option.aggr_obs)

    (y, yσ, ŷ) = applySpatialWeight(y, yσ, ŷ, cost_option, cost_option.spatial_weight)
    (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ)
    return (y, yσ, ŷ)
end

"""
    getData(model_output::LandWrapper, observations, cost_option)
    getData(model_output::NamedTuple, observations, cost_option)
    getData(model_output::AbstractArray, observations, cost_option)

# Arguments:
- `model_output`: a collection of SINDBAD model output time series as a time series of stacked land NT or as a preallocated array.
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_option`: information for a observation constraint on how it should be used to calculate the loss/metric of model performance
"""
getData

function getData(model_output::LandWrapper, observations, cost_option)
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
    # ymask = observations[obs_ind + 2]
    y, yσ, ŷ = getHarmonizedData(y, yσ, ŷ, cost_option)
    return (y, yσ, ŷ)
end


function getData(model_output::NamedTuple, observations, cost_option)
    obs_ind = cost_option.obs_ind
    mod_field = cost_option.mod_field
    mod_subfield = cost_option.mod_subfield
    ŷ = model_output
    sf_name = mod_subfield
    if !hasproperty(model_output, sf_name)
        sf_name = Symbol(String(mod_field) * "__" * String(mod_subfield))
    end
    ŷ = getproperty(model_output, sf_name)
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
    end
    # ymask = observations[obs_ind + 2]

    y, yσ, ŷ = getHarmonizedData(y, yσ, ŷ, cost_option)

    return (y, yσ, ŷ)
end

function getData(model_output::AbstractArray, observations, cost_option)
    obs_ind = cost_option.obs_ind
    ŷ = model_output[cost_option.mod_ind]
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
    end
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]
    y, yσ, ŷ = getHarmonizedData(y, yσ, ŷ, cost_option)
    return (y, yσ, ŷ)
end


"""
     getModelOutputView(_dat::AbstractArray{<:Any,N}) where N


"""
function getModelOutputView(_dat::AbstractArray{<:Any,N}) where N
    dim = 1
    inds = map(size(_dat)) do _
        ind = dim == 2 ? 1 : Colon()
        dim += 1
        ind
    end
    @view _dat[inds...]
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


"""
    spatialAggregation(dat, _, ::ConcatData)

# Arguments:
- `dat`: a data array/vector to aggregate
- `_`: unused argument
- `::ConcatData`: DESCRIPTION
"""
function spatialAggregation(dat, _, ::ConcatData)
    return dat
end
