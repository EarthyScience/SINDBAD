export temporalAggregation


function Base.view(x::AbstractArray, v::Sindbad.TimeAggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.f, subarray_t)
    Sindbad.TimeAggregatorViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end



function getTimeAggrArray(_dat::AbstractArray{T,2}) where {T}
    return _dat[:, :]
end

function getTimeAggrArray(_dat::AbstractArray{T,3}) where {T}
    return _dat[:, :, :]
end

function getTimeAggrArray(mod_dat::AbstractArray{T,4}) where {T}
    return _dat[:, :, :, :]
end


# works for everything for which only aggregation is needed
function temporalAggregation(dat, temporal_aggregator::Sindbad.TimeAggregator, dim = 1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return getTimeAggrArray(dat)
end

# works for everything for which only aggregation is needed
function temporalAggregation(dat, temporal_aggregator::Nothing, dim = 1)
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
