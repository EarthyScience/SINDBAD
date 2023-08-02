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
    return dat .- nanmean(dat)
end

function doMean(dat, ::Val{:mean})
    return mean(dat)
end

function doMean(dat, ::Val{:nanmean})
    return nanmean(dat)
end

# works for everything for which only aggregation is needed
function temporalAggregation(y, yσ, ŷ, cost_option)
    ŷ = view(ŷ, cost_option.time_aggr_ind, dim=1)
    if cost_option.temporal_aggr_obs
        y = view(y, cost_option.time_aggr_ind, dim=1)
        yσ = view(yσ, cost_option.time_aggr_ind, dim=1)
    end
    return y, yσ, ŷ
end

function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:no_diff})
    return temporalAggregation(y, yσ, ŷ, cost_option)
end

function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:anomaly})
    y, yσ, ŷ = temporalAggregation(y, yσ, ŷ, cost_option)
    return temporalAnomaly(y, yσ, ŷ, cost_option)
end

function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:iav})
    y_agg, yσ_agg, ŷ_agg = temporalAggregation(y, yσ, ŷ, cost_option)
    return temporalIAV(y, y_agg, yσ, yσ_agg, ŷ, ŷ_agg)
end

function temporalAnomaly(y, yσ, ŷ, cost_option)
    ŷ = doAnomaly(ŷ, cost_option.temporal_aggr_func)
    if cost_option.temporal_aggr_obs
        y = doAnomaly(y, cost_option.temporal_aggr_func)
    end
    return y, yσ, ŷ
end

function temporalIAV(y, y_agg, yσ, yσ_agg, ŷ, ŷ_agg)
    y .= y .- y_agg
    yσ .= yσ .- yσ_agg
    ŷ .= ŷ.- ŷ_agg
    return y, yσ, ŷ
end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:mean})
#     ŷ = doMean(ŷ, cost_option.temporal_aggr_func)
#     if cost_option.temporal_aggr_obs
#         y = doMean(y, cost_option.temporal_aggr_func)
#         yσ = doMean(yσ, cost_option.temporal_aggr_func)
#     end
#     return y, yσ, ŷ
# end


# function temporalAggregation(y, yσ, ŷ, _, ::Val{:day})
#     return y, yσ, ŷ
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:day_anomaly})
#     y, yσ, ŷ = temporalAnomaly(y, yσ, ŷ, cost_option)
#     return y, yσ, ŷ
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:day_msc})
#     return temporalAggregation(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:day_msc_anomaly})
#     y, yσ, ŷ = temporalAggregation(y, yσ, ŷ, cost_option)
#     return temporalAnomaly(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:month})
#     return temporalAggregation(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:month_anomaly})
#     y, yσ, ŷ = temporalAggregation(y, yσ, ŷ, cost_option)
#     return temporalAnomaly(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:month_msc})
#     return temporalAggregation(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:month_msc_anomaly})
#     y, yσ, ŷ = temporalAggregation(y, yσ, ŷ, cost_option)
#     return temporalAnomaly(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, cost_option, ::Val{:year})
#     return temporalAggregation(y, yσ, ŷ, cost_option)
# end

# function temporalAggregation(y, yσ, ŷ, _, ::Val{:year_anomaly})
#     y, yσ, ŷ = temporalAggregation(y, yσ, ŷ, cost_option)
#     return temporalAnomaly(y, yσ, ŷ, cost_option)
# end
