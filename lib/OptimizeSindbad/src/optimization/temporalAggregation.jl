export temporalAggregation


function Base.view(x::AbstractArray, v::Sindbad.TimeAggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.f, subarray_t)
    Sindbad.TimeAggregatorViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end

# works for everything for which only aggregation is needed
function temporalAggregation(dat, temporal_aggregator, dim = 1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return dat
end

function temporalAggregation(dat, temporal_aggregators, ::Val{:no_diff})
    return temporalAggregation(dat, first(temporal_aggregators))
end

function temporalAggregation(dat, temporal_aggregators, ::Val{:diff})
    dat_agg = temporalAggregation(dat, first(temporal_aggregators))
    dat_agg_to_remove = temporalAggregation(dat, last(temporal_aggregators))
    return dat_agg .- dat_agg_to_remove
end
