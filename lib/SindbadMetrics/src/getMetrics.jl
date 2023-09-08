export combineLoss
export filterCommonNaN
export getData
export getLoss
export getLossVector
export getModelOutputView
export prepCostOptions

"""
    aggregateData(dat, cost_option, ::TimeSpace)



# Arguments:
- `dat`: a data array/vector to aggregate
- `cost_option`: information for a observation constraint on how it should be used to calcuate the loss/metric of model performance
- `::TimeSpace`: DESCRIPTION
"""
function aggregateData(dat, cost_option, ::TimeSpace)
    dat = temporalAggregation(dat, cost_option.temporal_aggr, cost_option.temporal_aggr_type)
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_data_aggr)
    return dat
end

"""
    aggregateData(dat, cost_option, ::SpaceTime)



# Arguments:
- `dat`: a data array/vector to aggregate
- `cost_option`: information for a observation constraint on how it should be used to calcuate the loss/metric of model performance
- `::SpaceTime`: DESCRIPTION
"""
function aggregateData(dat, cost_option, ::SpaceTime)
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_data_aggr)
    dat = temporalAggregation(dat, cost_option.temporal_aggr, cost_option.temporal_aggr_type)
    return dat
end


"""
    applySpatialWeight(y, yσ, ŷ, cost_option, ::DoSpatialWeight)

return model and obs data after applying the area weight

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `idxs`: model simulation data/estimate
- `::DoSpatialWeight`: type dispatch for doing area weight
"""
function applySpatialWeight(y, yσ, ŷ, cost_option, ::DoSpatialWeight)
    yweight = observations[cost_option.obs_ind+3]
    y .= y .* yweight
    yσ .= yσ .* yweight
    ŷ .= ŷ .* yweight
    return y, yσ, ŷ
end


"""
    applySpatialWeight(y, yσ, ŷ, cost_option, ::DoNotSpatialWeight)

return model and obs data without applying the area weight

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `idxs`: model simulation data/estimate
- `::DoNotSpatialWeight`: type dispatch for doing area weight
"""
function applySpatialWeight(y, yσ, ŷ, _, ::DoNotSpatialWeight)
    return y, yσ, ŷ
end

"""
    combineLoss(loss_vector::AbstractArray, ::CostSum)

return the total of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::CostSum)
    return sum(loss_vector)
end

"""
    combineLoss(loss_vector, ::CostSum)

return the total of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector, ::CostSum)
    return sum(loss_vector)
end

"""
    combineLoss(loss_vector::AbstractArray, ::CostMinimum)

return the minimum of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::CostMinimum)
    return minimum(loss_vector)
end

"""
    combineLoss(loss_vector::AbstractArray, ::CostMaximum)

return the maximum of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::CostMaximum)
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
    filterCommonNaN(y, yσ, ŷ, idxs)

return model and obs data filtering for the common nan

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `idxs`: model simulation data/estimate
"""
@inline function filterCommonNaN(y, yσ, ŷ, idxs)
    # idxs = (.!isnan.(y .* yσ .* ŷ)) # TODO this has to be run because landWrapper produces a vector. So, dispatch with the inefficient versions without idxs argument
    return y[idxs], yσ[idxs], ŷ[idxs]
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
    # @debug sum(isInvalid.(y)), sum(isInvalid.(yσ)), sum(isInvalid.(ŷ))
    idxs = (.!isInvalid.(y .* yσ .* ŷ))
    return y[idxs], yσ[idxs], ŷ[idxs]
end



"""
    getData(model_output::landWrapper, observations, cost_option)



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
    # ymask = observations[obs_ind + 2]

    ŷ = aggregateData(ŷ, cost_option, cost_option.aggr_order)

    y, yσ = aggregateObsData(y, yσ,cost_option, cost_option.aggr_obs)

    return (y, yσ, ŷ)
end

"""
    getData(model_output::AbstractArray, observations, cost_option)



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

    #ŷ = aggregateData(ŷ, cost_option, cost_option.aggr_order)

    #y, yσ = aggregateObsData(y, yσ,cost_option, cost_option.aggr_obs)
    return (y, yσ, ŷ)
end

function aggregateObsData(y, yσ, cost_option, ::DoAggrObs)
    y = aggregateData(y, cost_option, cost_option.aggr_order)
    yσ = aggregateData(yσ, cost_option, cost_option.aggr_order)
    return y, yσ
end

function aggregateObsData(y, yσ, _, ::DoNotAggrObs)
    return y, yσ
end

"""
    getLossVector(observations, model_output::AbstractArray, cost_options)

returns a vector of losses for variables in info.cost_options.observational_constraints

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `model_output::AbstractArray`: a collection of SINDBAD model output time series as a preallocated array
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
"""
function getLossVector2(observations, model_output, cost_options)
    return [0,0,0]
end

function getLossVector(observations, model_output, cost_options)
    loss_vector = map(cost_options) do cost_option
    #for cost_option in cost_options
        #@code_warntype get_metric(cost_option)
        _lossMetric = get_metric(cost_option) #cost_option.cost_metric # bad
        _obs_ind = cost_option.obs_ind
        _mod_ind = cost_option.mod_ind
        _valids = cost_option.valids
        _weight = cost_option.cost_weight
        #y, yσ, ŷ =  base_ys(model_output, observations, _mod_ind, _obs_ind, _valids)
       # metr = loss(y, yσ, ŷ, _lossMetric) * _weight
        #l = innner_loss(_lossMetric, _obs_ind, _mod_ind, _valids, _weight, model_output, observations)
        #@show _weight
        #push!(loss_vector, metr)
        innner_loss(_lossMetric, _obs_ind, _mod_ind, _valids, _weight, model_output, observations)
    end
    #@show loss_vector
    return loss_vector
end

function get_metric(cost_option)
    return getfield(cost_option, :cost_metric)
end

function base_ys(model_output, observations, _mod_ind, _obs_ind, _valids)
    ŷ = model_output[_mod_ind]
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
    end
    y = observations[_obs_ind]
    yσ = observations[_obs_ind+1]
    y, yσ, ŷ = filterCommonNaN(y, yσ, ŷ, _valids)
    return y, yσ, ŷ
end

function innner_loss(_lossMetric, _obs_ind, _mod_ind, _valids, _weight, model_output, observations)
    ŷ = model_output[_mod_ind]
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
    end
    y = observations[_obs_ind]
    yσ = observations[_obs_ind+1]
    (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ, _valids)
    metr = loss(y, yσ, ŷ, _lossMetric) * _weight
    if isnan(metr)
        metr = oftype(metr, 1e19)
    end
    return metr
end


"""
    getLossVector(observations, model_output::landWrapper, cost_options)

returns a vector of losses for variables in info.cost_options.observational_constraints

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `model_output:::landWrapper`: a collection of SINDBAD model output as a time series of stacked land NT
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
"""
function getLossVector(observations, model_output::landWrapper, cost_options)
    loss_vector = map(cost_options) do cost_option
        #@debug "$(cost_option.variable)"
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        #@debug "size y, yσ, ŷ", size(y), size(yσ), size(ŷ)
        (y, yσ, ŷ) = applySpatialWeight(y, yσ, ŷ, cost_option, cost_option.spatial_weight)
        (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ)
        metr = loss(y, yσ, ŷ, lossMetric) * cost_option.cost_weight
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        #@debug "$(cost_option.variable) => $(nameof(typeof(lossMetric))): $(metr)"
        metr
    end
    #@debug "\n-------------------\n"
    return loss_vector
end

"""
    getModelOutputView(mod_dat::AbstractArray{T, 2})


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
    prepCostOptions(obs_array, cost_options)

remove all the variables that have less than minimum datapoints from being used in the optimization

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `cost_options`: a table listing each observation constraint and how it should be used to calcuate the loss/metric of model performance
"""
function prepCostOptions(observations, cost_options)
    valids=[]
    cost = []
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
        push!(cost, zero(eltype(y)))
        push!(valids, idxs)
    end
    cost = [_c for _c  in cost]
    cost_options = setTupleField(cost_options, (:valids, valids))
    cost_options = setTupleField(cost_options, (:is_valid, is_valid))
    cost_options = setTupleField(cost_options, (:cost, cost))
    cost_options = dropFields(cost_options, (:min_data_points, :temporal_data_aggr, :aggr_func,))
    cost_option_table = Table(cost_options)
    cost_options_table_filtered = filter(row -> row.is_valid === true , cost_option_table)
    return cost_options_table_filtered
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
