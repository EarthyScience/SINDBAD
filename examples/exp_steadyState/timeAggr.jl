using StatsBase: rle
using Statistics
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

struct AggViewInstance{T,N,D,P,AV<:Aggregator} <: AbstractArray{T,N}
    parent::P
    agg::AV
    dim::Val{D}
end
getdim(a::AggViewInstance{<:Any,<:Any,D}) where {D} = D

function Base.size(a::AggViewInstance, i)
    if i === getdim(a)
        size(a.agg.indices, 1)
    else
        size(a.parent, i)
    end
end

Base.size(a::AggViewInstance) = ntuple(i -> size(a, i), ndims(a))

function Base.getindex(a::AggViewInstance, I::Vararg{Int,N}) where {N}
    idim = getdim(a)
    indices = I
    indices = Base.setindex(indices, a.agg.indices[I[idim]], idim)
    a.agg.f(view(a.parent, indices...))
end

function Base.view(x::AbstractArray, v::Aggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.f, subarray_t)
    AggViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end

time = Date(2001):Day(1):Date(2010, 12, 31)
data = rand(20, length(time), 30);


monthlyview = create_aggregator(month.(time))
annualview = create_aggregator(year.(time))

monthlyview.indices

data_monthly = view(data, monthlyview, dim=2);

data_monthly[1, 1, 1]

function monthly_sum(data_monthly)
    sum(data_monthly)
end

@time monthly_sum(data_monthly)

mean(data[1, 1:31, 1])


data_monthly[2] == mean(data[32:31+28, :, :])

data_annual = view(data, annualview)

data_annual[1] == mean(data[1:365])

data_monthly .+ 1


doy = dayofyear.(time)
mscagg = Aggregator([findall(==(i), doy) for i in 1:365], mean)

mscview = view(data, mscagg, dim=2)