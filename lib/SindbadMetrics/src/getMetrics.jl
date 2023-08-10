export combineLoss
export filterCommonNaN
export filterConstraintMinimumDatapoints
export getData
export getLocObs!
export getLoss
export getLossVector
export getModelOutputView

"""
    aggregateData(dat, cost_option, Val{:timespace})

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
    aggregateData(dat, cost_option, Val{:spacetime})

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
    combineLoss(loss_vector::AbstractArray, Val{:sum})

return the total of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::Val{:sum})
    return sum(loss_vector)
end


"""
    combineLoss(loss_vector::AbstractArray, Val{:minimum})

return the minimum of cost of each constraint as the overall cost
"""
function combineLoss(loss_vector::AbstractArray, ::Val{:minimum})
    return minimum(loss_vector)
end

"""
    combineLoss(loss_vector::AbstractArray, Val{:maximum})

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


function getModelOutputView(_dat::AbstractArray{<:Any,N}) where N
    inds = ntuple(_->Colon(),N)
    inds = map(size(_data)) do _
        Colon()
    end
    @view _dat[inds...]
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
    spatialAggregation(dat, _, Val{:cat})

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `_`: unused argument
- `nothing`: DESCRIPTION
"""
function spatialAggregation(dat, _, ::Val{:cat})
    return dat
end
