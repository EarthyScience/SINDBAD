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

function temporalAggregation(dat, temporal_aggregator)
    return temporalAggregation(dat, first(temporal_aggregator))
end

function temporalAggregation(dat, temporal_aggregator, ::Val{:no_diff})
    return temporalAggregation(dat, first(temporal_aggregator))
end

function temporalAggregation(dat, temporal_aggregator, ::Val{:diff})
    dat_agg = temporalAggregation(dat, first(temporal_aggregator))
    dat_agg_to_remove = temporalAggregation(dat, last(temporal_aggregator))
    return dat_agg .- dat_agg_to_remove
end
