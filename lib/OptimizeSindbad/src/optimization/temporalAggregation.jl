export temporalAggregation


function Base.view(x::AbstractArray, v::Sindbad.TimeAggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.f, subarray_t)
    Sindbad.TimeAggregatorViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end

function doAnomaly(dat, ::Val{:mean})
    return dat .- mean(dat)
end

function doAnomaly(dat, ::Val{:nanmean})
    return dat .- Sindbad.nanmean(dat)
end

function doMean(dat, ::Val{:mean})
    return mean(dat)
end

function doMean(dat, ::Val{:nanmean})
    return Sindbad.nanmean(dat)
end

# works for everything for which only aggregation is needed
function temporalAggregation(dat, temporal_aggregator, dim = 1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return dat
end


function temporalAggregation(dat, cost_option, ::Val{:no_diff})
    return temporalAggregation(dat, cost_option.temporal_aggregator)
end

function temporalAggregation(dat, cost_option, ::Val{:anomaly})
    dat = temporalAggregation(dat, cost_option.temporal_aggregator)
    return temporalAnomaly(dat, cost_option)
end

function temporalAggregation(dat, cost_option, ::Val{:iav})
    t_aggregators = cost_option.temporal_aggregator
    dat_agg = temporalAggregation(dat, t_aggregators[1])
    dat_agg_to_remove = temporalAggregation(dat, t_aggregators[2])
    return temporalIAV(dat_agg, dat_agg_to_remove)
end


function temporalAnomaly(dat, cost_option)
    dat = doAnomaly(dat, cost_option.temporal_aggr_func)
    return dat
end

function temporalIAV(dat_base, dat_remove)
    return dat_base .- dat_remove
end