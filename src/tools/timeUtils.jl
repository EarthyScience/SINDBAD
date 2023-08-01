export TimeAggregator
export createTimeAggregator
export TimeAggregatorViewInstance

struct TimeAggregator{I,F}
    indices::I
    f::F
end

function createTimeAggregator(time, ::Val{:day_msc}, f=mean)
    days = dayofyear.(time)
    days_msc = unique(days)
    day_msc_agg = TimeAggregator([findall(==(dd), days) for dd in days_msc], f)
    return day_msc_agg
end

function createTimeAggregator(time, ::Val{:day_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:day), f)
end


function createTimeAggregator(time, ::Val{:day_msc_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:day_msc), f)
end

function createTimeAggregator(time, ::Val{:month_msc}, f=mean)
    months = month.(time)
    months_msc = unique(months)
    month_msc_agg = TimeAggregator([findall(==(mm), months) for mm in months_msc], f)
    return month_msc_agg
end


function createTimeAggregator(time, ::Val{:month_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:month), f)
end

function createTimeAggregator(time, ::Val{:month_msc_anomaly}, f=mean)
    return createTimeAggregator(time, Val(:month_msc), f)
end

function getIndicesForTimeGroups(groups)
    _, rl = rle(groups)
    cums = [0; cumsum(rl)]
    stepvectime = [cums[i]+1:cums[i+1] for i in 1:length(rl)]
    return stepvectime
end

function createTimeAggregator(time, ::Val{:month}, f=mean)
    stepvectime = getIndicesForTimeGroups(month.(time))
    month_agg = TimeAggregator(stepvectime, f)
    return month_agg
end

function createTimeAggregator(time, ::Val{:year}, f=mean)
    stepvectime = getIndicesForTimeGroups(year.(time))
    month_agg = TimeAggregator(stepvectime, f)
    return month_agg
end

function createTimeAggregator(time, ::Val{:day}, f=mean)
    stepvectime = [1:length(time)]
    day_agg = TimeAggregator(stepvectime, f)
    return day_agg
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
