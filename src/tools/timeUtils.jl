export createTimeAggregator
export TimeAggregator
export TimeAggregatorViewInstance

## base structs/functions for time aggregators
function getIndicesForTimeGroups(groups)
    _, rl = rle(groups)
    cums = [0; cumsum(rl)]
    stepvectime = [cums[i]+1:cums[i+1] for i in 1:length(rl)]
    return stepvectime
end

struct TimeAggregator{I,F}
    indices::I
    f::F
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


function getArType()
    return Val(:array)
    # return Val(:sized_array)
end

function getTimeArray(ar, ::Val{:sized_array})
    return SizedArray{Tuple{size(ar)...}, eltype(ar)}(ar)
end

function getTimeArray(ar, ::Val{:array})
    return ar
end

## time aggregators for model output and observations
function createTimeAggregator(time, t_step::Symbol, f=mean, is_model_time_step=false)
    return createTimeAggregator(time, Val(t_step), f, is_model_time_step)
end

function createTimeAggregator(time, ::Val{:mean}, f=mean)
    stepvectime = getTimeArray([1:length(time)], getArType())
    mean_agg = TimeAggregator(stepvectime, f)
    return [mean_agg, ]
end

function createTimeAggregator(time, ::Val{:day}, f=mean, is_model_time_step=false)
    stepvectime = [getTimeArray([t], getArType()) for t in 1:length(time)]
    day_agg = TimeAggregator(stepvectime, f)
    if is_model_time_step
        day_agg = nothing
    end
    return [day_agg, ]
end

function createTimeAggregator(time, ::Val{:day_anomaly}, f=mean, is_model_time_step=false)
    day_agg = createTimeAggregator(time, Val(:day), f, is_model_time_step)
    mean_agg = createTimeAggregator(time, Val(:mean), f)
    return [day_agg[1], mean_agg[1]]
end

function createTimeAggregator(time, ::Val{:day_iav}, f=mean, is_model_time_step=false)
    days = dayofyear.(time)
    day_aggr = createTimeAggregator(time, Val(:day), f, is_model_time_step)
    days_msc = unique(days)
    days_msc_inds = [findall(==(dd), days) for dd in days_msc]
    days_iav_inds = [getTimeArray(days_msc_inds[d], getArType()) for d in days]
    day_iav_agg = TimeAggregator(days_iav_inds, f)
    return [day_aggr[1], day_iav_agg]
end

function createTimeAggregator(time, ::Val{:day_msc}, f=mean, is_model_time_step=false)
    days = dayofyear.(time)
    days_msc = unique(days)
    days_ind = [getTimeArray(findall(==(dd), days), getArType()) for dd in days_msc]
    day_msc_agg = TimeAggregator(days_ind, f)
    return [day_msc_agg, ]
end

function createTimeAggregator(time, ::Val{:day_msc_anomaly}, f=mean, is_model_time_step=false)
    day_msc_agg = createTimeAggregator(time, Val(:day_msc), f, is_model_time_step)
    mean_agg = createTimeAggregator(time, Val(:mean), f)
    return [day_msc_agg[1], mean_agg[1]]
end

function createTimeAggregator(time, ::Val{:month}, f=mean, is_model_time_step=false)
    stepvectime = getIndicesForTimeGroups(month.(time))
    month_agg = TimeAggregator(stepvectime, f)
    return [month_agg, ]
end

function createTimeAggregator(time, ::Val{:month_anomaly}, f=mean, is_model_time_step=false)
    month_agg = createTimeAggregator(time, Val(:month), f, is_model_time_step)
    mean_agg = createTimeAggregator(time, Val(:mean), f)
    return [month_agg[1], mean_agg[1]]
end

function createTimeAggregator(time, ::Val{:month_iav}, f=mean, is_model_time_step=false)
    months = month.(time) # month for each time step, size = number of time steps
    month_aggr = createTimeAggregator(time, Val(:month), f, is_model_time_step) #to get the month per month, size = number of months
    months_series = Int.(view(months, month_aggr[1])) # aggregate the months per time step
    months_msc = unique(months) # get unique months
    months_msc_inds = [findall(==(mm), months) for mm in months_msc] # all timesteps per unique month
    months_iav_inds = [getTimeArray(months_msc_inds[mm], getArType()) for mm in months_series] # repeat monthlymsc indices for each month in time range
    month_iav_agg = TimeAggregator(months_iav_inds, f) # generate aggregator
    return [month_aggr[1], month_iav_agg]
end

function createTimeAggregator(time, ::Val{:month_msc}, f=mean, is_model_time_step=false)
    months = month.(time)
    months_msc = unique(months)
    month_msc_agg = TimeAggregator([getTimeArray(findall(==(mm), months), getArType()) for mm in months_msc], f)
    return [month_msc_agg, ]
end

function createTimeAggregator(time, ::Val{:month_msc_anomaly}, f=mean, is_model_time_step=false)
    month_msc_agg = createTimeAggregator(time, Val(:month_msc), f, is_model_time_step)
    mean_agg = createTimeAggregator(time, Val(:mean), f)
    return [month_msc_agg[1], mean_agg[1]]
end

function createTimeAggregator(time, ::Val{:year}, f=mean, is_model_time_step=false)
    stepvectime = getTimeArray(getIndicesForTimeGroups(year.(time)), getArType())
    year_agg = TimeAggregator(stepvectime, f)
    return [year_agg, ]
end

function createTimeAggregator(time, ::Val{:year_anomaly}, f=mean, is_model_time_step=false)
    year_agg = createTimeAggregator(time, Val(:year), f, is_model_time_step)
    mean_agg = createTimeAggregator(time, Val(:mean), f)
    return [year_agg[1], mean_agg[1]]
end

## spinup forcing related aggregators and functions
function getIndexForSelectedYear(years, sel_year)
    return getTimeArray(findall(==(sel_year), years), getArType())
end

function createTimeAggregator(time, ::Val{:all_years}, f=mean, is_model_time_step=false)
    stepvectime = getTimeArray([1:length(time)], getArType())
    all_agg = TimeAggregator(stepvectime, f)
    return [all_agg, ]
end

function createTimeAggregator(time, ::Val{:first_year}, f=mean, is_model_time_step=false)
    years = year.(time)
    first_year = minimum(years)
    year_inds = getIndexForSelectedYear(years, first_year)
    year_agg = TimeAggregator(year_inds, f)
    return [year_agg, ]
end

function createTimeAggregator(time, ::Val{:random_year}, f=mean, is_model_time_step=false)
    years = year.(time)
    random_year = rand(unique(years))
    year_inds = getIndexForSelectedYear(years, random_year)
    year_agg = TimeAggregator(year_inds, f)
    return [year_agg, ]
end

function createTimeAggregator(time, ::Val{:shuffle_years}, f=mean, is_model_time_step=false)
    years = year.(time)
    unique_years = unique(years)
    shuffled_unique_years = Sindbad.sample(unique_years, length(unique_years), replace=false)
    year_inds = getIndexForSelectedYear.(Ref(years), shuffled_unique_years)
    year_agg = TimeAggregator(year_inds, f)
    return [year_agg, ]
end

