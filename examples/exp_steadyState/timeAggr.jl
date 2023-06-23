using StatsBase: rle
using Dates

struct Aggregator{I,F}
    indices::I
    f::F
end

function create_aggregator(groups, f=mean)
    _, rl = rle(groups)
    cums = [0; cumsum(rl)]
    stepvectime = [cums[i]+1:cums[i+1] for i in 1:length(rl)]
    Aggregator(stepvectime, f)
end

struct AggViewInstance{T,N,P,AV<:Aggregator} <: AbstractArray{T,N}
    parent::P
    agg::AV
end
Base.size(a::AggViewInstance, i) = size(a.agg.indices, i)
Base.size(a::AggViewInstance) = size(a.agg.indices)
Base.getindex(a::AggViewInstance, i::Int) = a.agg.f(view(a.parent, a.agg.indices[i]))

function Base.view(x::AbstractArray, v::Aggregator)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.f, subarray_t)
    AggViewInstance{t,ndims(v.indices),typeof(x),typeof(v)}(x, v)
end


time = Date(2001):Day(1):Date(2010, 12, 31)
data = rand(length(time))

monthlyview = create_aggregator(month.(time))
annualview = create_aggregator(year.(time))

data_monthly = view(data, monthlyview)

data_monthly[1] == mean(data[1:31])
data_monthly[2] == mean(data[32:31+28])

data_annual = view(data, annualview)

data_annual[1] == mean(data[1:365])

data_monthly .+ 1