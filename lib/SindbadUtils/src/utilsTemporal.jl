export createTimeAggregator
export temporalAggregation
export TimeAggregator
export TimeAggregatorViewInstance

"""
    TimeAggregator{I, aggr_func}

define a new type of temporal aggregation

# Fields:
- `indices::I`: indices to be collected for aggregation
- `aggr_func::aggr_func`: a function to use for aggregation, defaults to mean
"""
struct TimeAggregator{I,aggr_func}
    indices::I
    aggr_func::aggr_func
end


"""
    TimeAggregatorViewInstance{T, N, D, P, AV <: TimeAggregator}

DOCSTRING

# Fields:
- `parent::P`: the parent data
- `agg::AV`: a view of the parent data
- `dim::Val{D}`: a val instance of the type that stores the dimension to be aggregated on
"""
struct TimeAggregatorViewInstance{T,N,D,P,AV<:TimeAggregator} <: AbstractArray{T,N}
    parent::P
    agg::AV
    dim::Val{D}
end

"""
    getdim(a::TimeAggregatorViewInstance{<:Any, <:Any, D})

get the dimension to aggregate for TimeAggregatorViewInstance type
"""
getdim(a::TimeAggregatorViewInstance{<:Any,<:Any,D}) where {D} = D


"""
    Base.size(a::TimeAggregatorViewInstance, i)

extend the size function for TimeAggregatorViewInstance type
"""
function Base.size(a::TimeAggregatorViewInstance, i)
    if i === getdim(a)
        size(a.agg.indices, 1)
    else
        size(a.parent, i)
    end
end

Base.size(a::TimeAggregatorViewInstance) = ntuple(i -> size(a, i), ndims(a))

"""
    Base.getindex(a::TimeAggregatorViewInstance, I::Vararg{Int, N})

extend the getindex function for TimeAggregatorViewInstance type
"""
function Base.getindex(a::TimeAggregatorViewInstance, I::Vararg{Int,N}) where {N}
    idim = getdim(a)
    indices = I
    indices = Base.setindex(indices, a.agg.indices[I[idim]], idim)
    a.agg.aggr_func(view(a.parent, indices...))
end

"""
    Base.view(x::AbstractArray, v::TimeAggregator; dim = 1)

extend the view function for TimeAggregatorViewInstance type

# Arguments:
- `x`: input array to be viewed
- `v`: time aggregator struct with indices and function
- `dim`: the dimension along which the aggregation should be done
"""
function Base.view(x::AbstractArray, v::TimeAggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.aggr_func, subarray_t)
    TimeAggregatorViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end


"""
    createTimeAggregator(date_vector, t_step::Symbol, aggr_func = mean, skip_aggregation = false)

DOCSTRING

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `t_step`: a string defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, t_step::String, aggr_func=mean, skip_aggregation=false)
    return createTimeAggregator(date_vector, getTimeAggregatorTypeInstance(t_step), aggr_func, skip_aggregation)
end

"""
    createTimeAggregator(date_vector, ::TimeMean, aggr_func = mean)

a function to create a temporal aggregation struct for temporal mean

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeMean`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
"""
function createTimeAggregator(date_vector, ::TimeMean, aggr_func=mean)
    stepvectime = getTimeArray([1:length(date_vector)], getTypeOfTimeIndexArray())
    mean_agg = TimeAggregator(stepvectime, aggr_func)
    return [mean_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeDay, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for daily time step

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeDay`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeDay, aggr_func=mean, skip_aggregation=false)
    stepvectime = [getTimeArray([t], getTypeOfTimeIndexArray()) for t in 1:length(date_vector)]
    day_agg = TimeAggregator(stepvectime, aggr_func)
    if skip_aggregation
        day_agg = nothing
    end
    return [day_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeDayAnomaly, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for daily anomalies

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeDayAnomaly`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeDayAnomaly, aggr_func=mean, skip_aggregation=false)
    day_agg = createTimeAggregator(date_vector, TimeDay(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [day_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, ::TimeDayIAV, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for anomalies of daily interannual variability

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeDayIAV`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeDayIAV, aggr_func=mean, skip_aggregation=false)
    days = dayofyear.(date_vector)
    day_aggr = createTimeAggregator(date_vector, TimeDay(), aggr_func, skip_aggregation)
    daysMSC = unique(days)
    daysMSC_inds = [findall(==(dd), days) for dd in daysMSC]
    daysIAV_inds = [getTimeArray(daysMSC_inds[d], getTypeOfTimeIndexArray()) for d in days]
    dayIAV_agg = TimeAggregator(daysIAV_inds, aggr_func)
    return [day_aggr[1], dayIAV_agg]
end

"""
    createTimeAggregator(date_vector, ::TimeDayMSC, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for daily mean seasonal cycle

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeDayMSC`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeDayMSC, aggr_func=mean, skip_aggregation=false)
    days = dayofyear.(date_vector)
    daysMSC = unique(days)
    days_ind = [getTimeArray(findall(==(dd), days), getTypeOfTimeIndexArray()) for dd in daysMSC]
    dayMSC_agg = TimeAggregator(days_ind, aggr_func)
    return [dayMSC_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeDayMSCAnomaly, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for anomalies of daily mean seasonal cycle

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeDayMSCAnomaly`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeDayMSCAnomaly, aggr_func=mean, skip_aggregation=false)
    dayMSC_agg = createTimeAggregator(date_vector, TimeDayMSC(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [dayMSC_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, ::TimeMonth, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for monthly time step


# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeMonth`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeMonth, aggr_func=mean, skip_aggregation=false)
    stepvectime = getIndicesForTimeGroups(month.(date_vector))
    month_agg = TimeAggregator(stepvectime, aggr_func)
    return [month_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeMonthAnomaly, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for anomalies of monthly time series


# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeMonthAnomaly`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeMonthAnomaly, aggr_func=mean, skip_aggregation=false)
    month_agg = createTimeAggregator(date_vector, TimeMonth(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [month_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, ::TimeMonthIAV, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for interannual variability of monthly time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeMonthIAV`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeMonthIAV, aggr_func=mean, skip_aggregation=false)
    months = month.(date_vector) # month for each time step, size = number of time steps
    month_aggr = createTimeAggregator(date_vector, TimeMonth(), aggr_func, skip_aggregation) #to get the month per month, size = number of months
    months_series = Int.(view(months, month_aggr[1])) # aggregate the months per time step
    monthsMSC = unique(months) # get unique months
    monthsMSC_inds = [findall(==(mm), months) for mm in monthsMSC] # all timesteps per unique month
    monthsIAV_inds = [getTimeArray(monthsMSC_inds[mm], getTypeOfTimeIndexArray()) for mm in months_series] # repeat monthlymsc indices for each month in time range
    monthIAV_agg = TimeAggregator(monthsIAV_inds, aggr_func) # generate aggregator
    return [month_aggr[1], monthIAV_agg]
end

"""
    createTimeAggregator(date_vector, ::TimeMonthMSC, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for mean seasonal cycle of monthly time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeMonthMSC`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeMonthMSC, aggr_func=mean, skip_aggregation=false)
    months = month.(date_vector)
    monthsMSC = unique(months)
    t_monthMSC_agg = TimeAggregator([getTimeArray(findall(==(mm), months), getTypeOfTimeIndexArray()) for mm in monthsMSC], aggr_func)
    return [t_monthMSC_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeMonthMSCAnomaly, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for anomalies of mean seasonal cycle of monthly time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeMonthMSCAnomaly`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeMonthMSCAnomaly, aggr_func=mean, skip_aggregation=false)
    t_monthMSC_agg = createTimeAggregator(date_vector, TimeMonthMSC(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [t_monthMSC_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, ::TimeYear, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for annual time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeYear`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeYear, aggr_func=mean, skip_aggregation=false)
    stepvectime = getTimeArray(getIndicesForTimeGroups(year.(date_vector)), getTypeOfTimeIndexArray())
    year_agg = TimeAggregator(stepvectime, aggr_func)
    return [year_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeYearAnomaly, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for anomalies of annual time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeYearAnomaly`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeYearAnomaly, aggr_func=mean, skip_aggregation=false)
    year_agg = createTimeAggregator(date_vector, TimeYear(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [year_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, ::TimeallYears, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct returning the data of all years

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeAllYears`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeAllYears, aggr_func=mean, skip_aggregation=false)
    stepvectime = getTimeArray([1:length(date_vector)], getTypeOfTimeIndexArray())
    all_agg = TimeAggregator(stepvectime, aggr_func)
    return [all_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeFirstYear, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for retrieving the data of the first year in the time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeFirstYear`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeFirstYear, aggr_func=mean, skip_aggregation=false)
    years = year.(date_vector)
    first_year = minimum(years)
    year_inds = getIndexForSelectedYear(years, first_year)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeRandomYear, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for retrieving the data of a random year within the time series

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeRandomYear`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeRandomYear, aggr_func=mean, skip_aggregation=false)
    years = year.(date_vector)
    random_year = rand(unique(years))
    year_inds = getIndexForSelectedYear(years, random_year)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

"""
    createTimeAggregator(date_vector, ::TimeShuffleYears, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for shuffling the years of the data

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `::TimeShuffleYears`: a type defining the aggregation time target
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
"""
function createTimeAggregator(date_vector, ::TimeShuffleYears, aggr_func=mean, skip_aggregation=false)
    years = year.(date_vector)
    unique_years = unique(years)
    shuffled_unique_years = sample(unique_years, length(unique_years), replace=false)
    year_inds = getIndexForSelectedYear.(Ref(years), shuffled_unique_years)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end


"""
    getTypeOfTimeIndexArray()

a helper functio to easily switch the array type for indices of the TimeAggregator object
"""
function getTypeOfTimeIndexArray(_type=:array)
    if _type == :array
        return Val(:array)
    else
        return Val(_type)
    end
end



"""
    getIndexForSelectedYear(years, sel_year)

a helper function to get the indices of the first year from the date vector
"""
function getIndexForSelectedYear(years, sel_year)
    return getTimeArray(findall(==(sel_year), years), getTypeOfTimeIndexArray())
end


"""
    getIndicesForTimeGroups(groups)

a helper function to get the indices of the date group of the time series
"""
function getIndicesForTimeGroups(groups)
    _, rl = rle(groups)
    cums = [0; cumsum(rl)]
    stepvectime = [cums[i]+1:cums[i+1] for i in 1:length(rl)]
    return stepvectime
end


"""
    getTimeArray(ar, Val{:sized_array})

a helper function to get the array of indices as static array
"""
function getTimeArray(ar, ::Val{:sized_array})
    return SizedArray{Tuple{size(ar)...},eltype(ar)}(ar)
end

"""
    getTimeArray(ar, Val{:array})

a helper function to get the array of indices as normal array
"""
function getTimeArray(ar, ::Val{:array})
    return ar
end



"""
    getTimeAggrArray(_dat::AbstractArray{T, 2})

a helper function to instantiate an array from the TimeAggregatorViewInstance for N-dimensional array
"""
function getTimeAggrArray(_dat::AbstractArray{<:Any,N}) where N
    inds = ntuple(_->Colon(),N)
    inds = map(size(_dat)) do _
        Colon()
    end
    _dat[inds...]
end


# # works for everything for which aggregator is needed
# """
#     temporalAggregation(dat::AxisKeys.KeyedArray, temporal_aggregator::TimeAggregator, dim = 1)

# a temporal aggregation function to aggregate the data using a given aggregator when the input data is a KeyedArray

# # Arguments:
# - `dat`: a data array/vector to aggregate
# - `temporal_aggregator`: a type defining the aggregation time target
# - `dim`: the dimension along which the aggregation should be done
# """
# function temporalAggregation(dat, temporal_aggregator::TimeAggregator, dim=1)
#     dat = view(dat, temporal_aggregator, dim=dim)
#     return dat
# end

# works for everything for which aggregator is needed
"""
    temporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim = 1)

a temporal aggregation function to aggregate the data using a given aggregator when the input data is an array

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregator`: a time aggregator struct with indices and function to do aggregation
- `dim`: the dimension along which the aggregation should be done
"""
function temporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return dat
end

"""
    temporalAggregation(dat::SubArray, temporal_aggregator::TimeAggregator, dim = 1)

a temporal aggregation function to aggregate the data using a given aggregator when the input data is a view

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregator`: a time aggregator struct with indices and function to do aggregation
- `dim`: the dimension along which the aggregation should be done
"""
function temporalAggregation(dat::SubArray, temporal_aggregator::TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return getTimeAggrArray(dat)
end

# works for everything for which no aggregation is needed
"""
    temporalAggregation(dat, temporal_aggregator::Nothing, dim = 1)

a dummy temporal aggregation function to return the original data

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregator`: a time aggregator struct with indices and function to do aggregation
- `dim`: the dimension along which the aggregation should be done
"""
function temporalAggregation(dat, temporal_aggregator::Nothing, dim=1)
    return dat
end

"""
    temporalAggregation(dat, temporal_aggregators, TNoDiff)

a dummy temporal aggregation function to aggregate the data using a given aggregator without removing/subtracting a second array

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregators`: a vector of time aggregator structs with indices and function to do aggregation
- `::TimeNoDiff`: a type defining that the aggregator does not require removing/reducing values from original time series
"""
function temporalAggregation(dat, temporal_aggregators, ::TimeNoDiff)
    return temporalAggregation(dat, first(temporal_aggregators))
end

"""
    temporalAggregation(dat, temporal_aggregators, TDiff})

a dummy temporal aggregation function to aggregate the data using a given aggregator including removal/subtraction of second array

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregators`: a vector of time aggregator structs with indices and function to do aggregation
- `::TimeDiff`: a type defining that the aggregator requires removing/reducing values from original time series. First aggregator aggregates the main time series, second aggregagor aggregates to the time series to be removed.
"""
function temporalAggregation(dat, temporal_aggregators, ::TimeDiff)
    dat_agg = temporalAggregation(dat, first(temporal_aggregators))
    dat_agg_to_remove = temporalAggregation(dat, last(temporal_aggregators))
    return dat_agg .- dat_agg_to_remove
end


# function getTimeAggrArray(_dat::AbstractArray{T,2}) where {T}
#     return _dat[:, :]
# end

# function getTimeAggrArray(_dat::AbstractArray{<:Any,N}) where N
#     inds = ntuple(_->Colon(),N)
#     inds = map(size(_data)) do _
#         Colon()
#     end
#     _dat[inds...]
# end

# """
#     getTimeAggrArray(_dat::AbstractArray{T, 3})

# DOCSTRING
# """
# function getTimeAggrArray(_dat::AbstractArray{T,3}) where {T}
#     return _dat[:, :, :]
# end

# """
#     getTimeAggrArray(_dat::AbstractArray{T, 4})

# DOCSTRING
# """
# function getTimeAggrArray(_dat::AbstractArray{T,4}) where {T}
#     return _dat[:, :, :, :]
# end
