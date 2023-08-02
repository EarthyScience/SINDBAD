export createTimeAggregator
export TimeAggregator
export TimeAggregatorViewInstance

struct TimeAggregator{I,F}
    indices::I
    f::F
end

function createTimeAggregator(time, t_step::Symbol, f=mean)
    return createTimeAggregator(time, Val(t_step), f)
end

function createTimeAggregator(time, ::Val{:mean}, f=mean)
    stepvectime = [1:length(time)]
    mean_agg = TimeAggregator(stepvectime, f)
    return mean_agg
end

function createTimeAggregator(time, ::Val{:day}, f=mean)
    stepvectime = [[t] for t in 1:length(time)]
    day_agg = TimeAggregator(stepvectime, f)
    return day_agg
end

function createTimeAggregator(time, ::Val{:day_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:day), f)
end

function createTimeAggregator(time, ::Val{:day_iav}, f=mean)
    days = dayofyear.(time)
    day_aggr = createTimeAggregator(time, Val(:day), f)
    days_msc = unique(days)
    days_msc_inds = [findall(==(dd), days) for dd in days_msc]
    days_iav_inds = [days_msc_inds[d] for d in days]
    day_iav_agg = TimeAggregator(days_iav_inds, f)
    return (day_aggr, day_iav_agg)
end

function createTimeAggregator(time, ::Val{:day_msc}, f=mean)
    days = dayofyear.(time)
    days_msc = unique(days)
    day_msc_agg = TimeAggregator([findall(==(dd), days) for dd in days_msc], f)
    return day_msc_agg
end

function createTimeAggregator(time, ::Val{:day_msc_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:day_msc), f)
end

function createTimeAggregator(time, ::Val{:month}, f=mean)
    stepvectime = getIndicesForTimeGroups(month.(time))
    month_agg = TimeAggregator(stepvectime, f)
    return month_agg
end

function createTimeAggregator(time, ::Val{:month_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:month), f)
end

function createTimeAggregator(time, ::Val{:month_iav}, f=mean)
    months = month.(time) # month for each time step, size = number of time steps
    month_aggr = createTimeAggregator(time, Val(:month), f) #to get the month per month, size = number of months
    months_series=Int.(view(months, month_aggr)) # aggregate the months per time step
    months_msc = unique(months) # get unique months
    months_msc_inds = [findall(==(mm), months) for mm in months_msc] # all timesteps per unique month
    months_iav_inds = [months_msc_inds[mm] for mm in months_series] # repeat monthlymsc indices for each month in time range
    month_iav_agg = TimeAggregator(months_iav_inds, f) # generate aggregator
    return (month_aggr, month_iav_agg)
end

function createTimeAggregator(time, ::Val{:month_msc}, f=mean)
    months = month.(time)
    months_msc = unique(months)
    month_msc_agg = TimeAggregator([findall(==(mm), months) for mm in months_msc], f)
    return month_msc_agg
end

function createTimeAggregator(time, ::Val{:month_msc_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:month_msc), f)
end

function createTimeAggregator(time, ::Val{:year}, f=mean)
    stepvectime = getIndicesForTimeGroups(year.(time))
    year_agg = TimeAggregator(stepvectime, f)
    return year_agg
end

function createTimeAggregator(time, ::Val{:year_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:year), f)
end


function getIndicesForTimeGroups(groups)
    _, rl = rle(groups)
    cums = [0; cumsum(rl)]
    stepvectime = [cums[i]+1:cums[i+1] for i in 1:length(rl)]
    return stepvectime
end

struct TimeAggregatorViewInstance{T,N,D,P,AV<:TimeAggregator} <: AbstractArray{T,N}
    parent::P
    agg::AV
    dim::Val{D}
end

getdim(a::TimeAggregatorViewInstance{<:Any,<:Any,D}) where {D} = D

function Base.size(a::TimeAggregatorViewInstance, i)
    if i === getdim(a)
        size(a.agg.indices, 1)
    else
        size(a.parent, i)
    end
end

Base.size(a::TimeAggregatorViewInstance) = ntuple(i -> size(a, i), ndims(a))

function Base.getindex(a::TimeAggregatorViewInstance, I::Vararg{Int,N}) where {N}
    idim = getdim(a)
    indices = I
    indices = Base.setindex(indices, a.agg.indices[I[idim]], idim)
    a.agg.f(view(a.parent, indices...))
end
