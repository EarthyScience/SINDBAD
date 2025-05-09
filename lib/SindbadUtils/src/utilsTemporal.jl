export createTimeAggregator
export getTimeAggregatorTypeInstance
export temporalAggregation

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
    createTimeAggregator(date_vector, t_step, aggr_func = mean, skip_aggregation = false)

a function to create a temporal aggregation struct for a given time step 

# Arguments:
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
- `t_step`: a string/Symbol/Type defining the aggregation time target with different types as follows:
  - `::Union{String, Symbol}`: a string/Symbol defining the aggregation time target from the settings
- `aggr_func`: a function to use for aggregation, defaults to mean
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false

# Returns:
- `::Vector{TimeAggregator}`: a vector of TimeAggregator structs

# t_step:
$(methodsOf(TimeAggregation))
"""
createTimeAggregator


function createTimeAggregator(date_vector, t_step::Union{String, Symbol}, aggr_func=mean, skip_aggregation=false)
    return createTimeAggregator(date_vector, getTimeAggregatorTypeInstance(t_step), aggr_func, skip_aggregation)
end

function createTimeAggregator(date_vector, ::TimeMean, aggr_func=mean, skip_aggregation=false)
    stepvectime = getTimeArray([1:length(date_vector)], getTypeOfTimeIndexArray())
    mean_agg = TimeAggregator(stepvectime, aggr_func)
    return [mean_agg,]
end

function createTimeAggregator(date_vector, ::TimeDay, aggr_func=mean, skip_aggregation=false)
    stepvectime = getIndicesForTimeGroups(day.(date_vector))
    day_agg = TimeAggregator(stepvectime, aggr_func)
    if skip_aggregation
        day_agg = nothing
    end
    return [day_agg,]
end

function createTimeAggregator(date_vector, ::TimeDayAnomaly, aggr_func=mean, skip_aggregation=false)
    day_agg = createTimeAggregator(date_vector, TimeDay(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [day_agg[1], mean_agg[1]]
end

function createTimeAggregator(date_vector, ::TimeDayIAV, aggr_func=mean, skip_aggregation=false)
    days = dayofyear.(date_vector)
    day_aggr = createTimeAggregator(date_vector, TimeDay(), aggr_func, skip_aggregation)
    daysMsc = unique(days)
    daysMsc_inds = [findall(==(dd), days) for dd in daysMsc]
    daysIav_inds = [getTimeArray(daysMsc_inds[d], getTypeOfTimeIndexArray()) for d in days]
    dayIav_agg = TimeAggregator(daysIav_inds, aggr_func)
    return [day_aggr[1], dayIav_agg]
end

function createTimeAggregator(date_vector, ::TimeDayMSC, aggr_func=mean, skip_aggregation=false)
    days = dayofyear.(date_vector)
    daysMsc = unique(days)
    days_ind = [getTimeArray(findall(==(dd), days), getTypeOfTimeIndexArray()) for dd in daysMsc]
    dat_msc_agg = TimeAggregator(days_ind, aggr_func)
    return [dat_msc_agg,]
end

function createTimeAggregator(date_vector, ::TimeDayMSCAnomaly, aggr_func=mean, skip_aggregation=false)
    dat_msc_agg = createTimeAggregator(date_vector, TimeDayMSC(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [dat_msc_agg[1], mean_agg[1]]
end


function createTimeAggregator(date_vector, ::TimeHour, aggr_func=mean, skip_aggregation=false)
    stepvectime = getIndicesForTimeGroups(hour.(date_vector))
    hour_agg = TimeAggregator(stepvectime, aggr_func)
    if skip_aggregation
        hour_agg = nothing
    end
    return [hour_agg,]
end

function createTimeAggregator(date_vector, ::TimeHourAnomaly, aggr_func=mean, skip_aggregation=false)
    hour_agg = createTimeAggregator(date_vector, TimeHour(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [hour_agg[1], mean_agg[1]]
end

function createTimeAggregator(date_vector, ::TimeHourDayMean, aggr_func=mean, skip_aggregation=false)
    hours = hour.(date_vector)
    hours_day = unique(hours)
    t_hour_msc_agg = TimeAggregator([getTimeArray(findall(==(hh), hours), getTypeOfTimeIndexArray()) for hh in hours_day], aggr_func)
    return [t_hour_msc_agg,]
end

function createTimeAggregator(date_vector, ::TimeMonth, aggr_func=mean, skip_aggregation=false)
    stepvectime = getIndicesForTimeGroups(month.(date_vector))
    month_agg = TimeAggregator(stepvectime, aggr_func)
    return [month_agg,]
end

function createTimeAggregator(date_vector, ::TimeMonthAnomaly, aggr_func=mean, skip_aggregation=false)
    month_agg = createTimeAggregator(date_vector, TimeMonth(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [month_agg[1], mean_agg[1]]
end

function createTimeAggregator(date_vector, ::TimeMonthIAV, aggr_func=mean, skip_aggregation=false)
    months = month.(date_vector) # month for each time step, size = number of time steps
    month_aggr = createTimeAggregator(date_vector, TimeMonth(), aggr_func, skip_aggregation) #to get the month per month, size = number of months
    months_series = Int.(view(months, month_aggr[1])) # aggregate the months per time step
    monthsMsc = unique(months) # get unique months
    monthsMsc_inds = [findall(==(mm), months) for mm in monthsMsc] # all timesteps per unique month
    monthsIav_inds = [getTimeArray(monthsMsc_inds[mm], getTypeOfTimeIndexArray()) for mm in months_series] # repeat monthlymsc indices for each month in time range
    monthIav_agg = TimeAggregator(monthsIav_inds, aggr_func) # generate aggregator
    return [month_aggr[1], monthIav_agg]
end

function createTimeAggregator(date_vector, ::TimeMonthMSC, aggr_func=mean, skip_aggregation=false)
    months = month.(date_vector)
    monthsMsc = unique(months)
    t_month_msc_agg = TimeAggregator([getTimeArray(findall(==(mm), months), getTypeOfTimeIndexArray()) for mm in monthsMsc], aggr_func)
    return [t_month_msc_agg,]
end

function createTimeAggregator(date_vector, ::TimeMonthMSCAnomaly, aggr_func=mean, skip_aggregation=false)
    t_month_msc_agg = createTimeAggregator(date_vector, TimeMonthMSC(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [t_month_msc_agg[1], mean_agg[1]]
end

function createTimeAggregator(date_vector, ::TimeYear, aggr_func=mean, skip_aggregation=false)
    stepvectime = getTimeArray(getIndicesForTimeGroups(year.(date_vector)), getTypeOfTimeIndexArray())
    year_agg = TimeAggregator(stepvectime, aggr_func)
    return [year_agg,]
end

function createTimeAggregator(date_vector, ::TimeYearAnomaly, aggr_func=mean, skip_aggregation=false)
    year_agg = createTimeAggregator(date_vector, TimeYear(), aggr_func, skip_aggregation)
    mean_agg = createTimeAggregator(date_vector, TimeMean(), aggr_func)
    return [year_agg[1], mean_agg[1]]
end

function createTimeAggregator(date_vector, ::TimeAllYears, aggr_func=mean, skip_aggregation=false)
    stepvectime = getTimeArray([1:length(date_vector)], getTypeOfTimeIndexArray())
    all_agg = TimeAggregator(stepvectime, aggr_func)
    return [all_agg,]
end

function createTimeAggregator(date_vector, ::TimeFirstYear, aggr_func=mean, skip_aggregation=false)
    years = year.(date_vector)
    first_year = minimum(years)
    year_inds = getIndexForSelectedYear(years, first_year)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

function createTimeAggregator(date_vector, ::TimeRandomYear, aggr_func=mean, skip_aggregation=false)
    years = year.(date_vector)
    random_year = rand(unique(years))
    year_inds = getIndexForSelectedYear(years, random_year)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

function createTimeAggregator(date_vector, ::TimeShuffleYears, aggr_func=mean, skip_aggregation=false)
    years = year.(date_vector)
    unique_years = unique(years)
    shuffled_unique_years = sample(unique_years, length(unique_years), replace=false)
    year_inds = getIndexForSelectedYear.(Ref(years), shuffled_unique_years)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end


"""
    getTimeAggregatorTypeInstance(aggr)

Creates and returns a time aggregator instance based on the provided aggregation.

# Arguments
- `aggr::Symbol`: Symbol specifying the type of time aggregation to be performed
- `aggr::String`: String specifying the type of time aggregation to be performed

# Returns
An instance of the corresponding time aggregator type.

# Notes:
- A similar approach `getTypeInstanceForNamedOptions` is used in `SindbadSetup` for creating types of other named option
"""
getTimeAggregatorTypeInstance

function getTimeAggregatorTypeInstance(aggr::Symbol)
    return getTimeAggregatorTypeInstance(string(aggr))
end

function getTimeAggregatorTypeInstance(aggr::String)
    uc_first = toUpperCaseFirst(aggr, "Time")
    return getfield(SindbadUtils, uc_first)()
end


"""
    getTypeOfTimeIndexArray(_type=:array)

a helper functio to easily switch the array type for indices of the TimeAggregator object
"""
function getTypeOfTimeIndexArray(_type=:array)
    time_type = TimeArray()
    if _type == :sized_array
        time_type = TimeSizedArray()
    end
    return time_type
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
    getTimeArray(ar, ::TimeSizedArray || ::TimeArray)

a helper function to get the array of indices

# Arguments:
- `ar`: an array of time
- array type: a type defining the type of array to be returned
    - `::TimeSizedArray`: indices as static array
    - `::TimeArray`: indices as normal array
"""
function getTimeArray(ar, ::TimeSizedArray)
    return SizedArray{Tuple{size(ar)...},eltype(ar)}(ar)
end

function getTimeArray(ar, ::TimeArray)
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


"""
    doTemporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim = 1)

a temporal aggregation function to aggregate the data using a given aggregator when the input data is an array

# Arguments:
- `dat`: a data array/vector to aggregate with function for the following types:
  - `::AbstractArray`: an array
  - `::SubArray`: a view of an array
  - `::Nothing`: a dummy type to return the input and do no aggregation data
- `temporal_aggregator`: a time aggregator struct with indices and function to do aggregation
- `dim`: the dimension along which the aggregation should be done
"""
doTemporalAggregation

function doTemporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return getTimeAggrArray(dat)
end

function doTemporalAggregation(dat::SubArray, temporal_aggregator::TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return getTimeAggrArray(dat)
end

function doTemporalAggregation(dat, temporal_aggregator::Nothing, dim=1)
    return dat
end

"""
    temporalAggregation(dat, temporal_aggregators, aggregation_type)

a temporal aggregation function to aggregate the data using a vector of aggregators

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregators`: a vector of time aggregator structs with indices and function to do aggregation
- aggregation_type: a type defining the type of aggregation to be done as follows:
    - `::TimeNoDiff`: a type defining that the aggregator does not require removing/reducing values from original time series
    - `::TimeDiff`: a type defining that the aggregator requires removing/reducing values from original time series. First aggregator aggregates the main time series, second aggregator aggregates to the time series to be removed.
    - `::TimeIndexed`: a type defining that the aggregator requires indexing the original time series
"""
temporalAggregation

function temporalAggregation(dat, temporal_aggregators, ::TimeIndexed)
    return dat[first(temporal_aggregators).indices...]
end

function temporalAggregation(dat, temporal_aggregators, ::TimeNoDiff)
    return doTemporalAggregation(dat, first(temporal_aggregators))
end

function temporalAggregation(dat, temporal_aggregators, ::TimeDiff)
    dat_agg = doTemporalAggregation(dat, first(temporal_aggregators))
    dat_agg_to_remove = doTemporalAggregation(dat, last(temporal_aggregators))
    return dat_agg .- dat_agg_to_remove
end
