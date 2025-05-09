
export TimeType
abstract type TimeType <: SindbadType end
purpose(::Type{TimeType}) = "Abstract type for implementing time subset and aggregation types in SINDBAD"

# ------------------------- time aggregator ------------------------------------------------------------
export TimeAggregation
export TimeAllYears
export TimeArray
export TimeHour
export TimeHourAnomaly
export TimeHourDayMean
export TimeDay
export TimeDayAnomaly
export TimeDayIAV
export TimeDayMSC
export TimeDayMSCAnomaly
export TimeDiff
export TimeFirstYear
export TimeIndexed
export TimeMean
export TimeMonth
export TimeMonthAnomaly
export TimeMonthIAV
export TimeMonthMSC
export TimeMonthMSCAnomaly
export TimeNoDiff
export TimeRandomYear
export TimeShuffleYears
export TimeSizedArray
export TimeYear
export TimeYearAnomaly
export TimeAggregator
export TimeAggregatorViewInstance


# ------------------------- time aggregator --------------------------------
"""
    TimeAggregator{I, aggr_func}

define a new type of temporal aggregation

# Fields:
- `indices::I`: indices to be collected for aggregation
- `aggr_func::aggr_func`: a function to use for aggregation, defaults to mean
"""
struct TimeAggregator{I,aggr_func} <: TimeType
    indices::I
    aggr_func::aggr_func
end


"""
    TimeAggregatorViewInstance{T, N, D, P, AV <: TimeAggregator}



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


abstract type TimeAggregation <: TimeType end
purpose(::Type{TimeAggregation}) = "Abstract type for time aggregation methods in SINDBAD"

struct TimeAllYears <: TimeAggregation end
purpose(::Type{TimeAllYears}) = "aggregation/slicing to include all years"

struct TimeArray <: TimeAggregation end
purpose(::Type{TimeArray}) = "use array-based time aggregation"

struct TimeHour <: TimeAggregation end
purpose(::Type{TimeHour}) = "aggregation to hourly time steps"

struct TimeHourAnomaly <: TimeAggregation end
purpose(::Type{TimeHourAnomaly}) = "aggregation to hourly anomalies"

struct TimeHourDayMean <: TimeAggregation end
purpose(::Type{TimeHourDayMean}) = "aggregation to mean of hourly data over days"

struct TimeDay <: TimeAggregation end
purpose(::Type{TimeDay}) = "aggregation to daily time steps"

struct TimeDayAnomaly <: TimeAggregation end
purpose(::Type{TimeDayAnomaly}) = "aggregation to daily anomalies"

struct TimeDayIAV <: TimeAggregation end
purpose(::Type{TimeDayIAV}) = "aggregation to daily IAV"

struct TimeDayMSC <: TimeAggregation end
purpose(::Type{TimeDayMSC}) = "aggregation to daily MSC"

struct TimeDayMSCAnomaly <: TimeAggregation end
purpose(::Type{TimeDayMSCAnomaly}) = "aggregation to daily MSC anomalies"

struct TimeDiff <: TimeAggregation end
purpose(::Type{TimeDiff}) = "aggregation to time differences, e.g. monthly anomalies"

struct TimeFirstYear <: TimeAggregation end
purpose(::Type{TimeFirstYear}) = "aggregation/slicing of the first year"

struct TimeIndexed <: TimeAggregation end
purpose(::Type{TimeIndexed}) = "aggregation using time indices, e.g., TimeFirstYear"

struct TimeMean <: TimeAggregation end
purpose(::Type{TimeMean}) = "aggregation to mean over all time steps"

struct TimeMonth <: TimeAggregation end
purpose(::Type{TimeMonth}) = "aggregation to monthly time steps"

struct TimeMonthAnomaly <: TimeAggregation end
purpose(::Type{TimeMonthAnomaly}) = "aggregation to monthly anomalies"

struct TimeMonthIAV <: TimeAggregation end
purpose(::Type{TimeMonthIAV}) = "aggregation to monthly IAV"

struct TimeMonthMSC <: TimeAggregation end
purpose(::Type{TimeMonthMSC}) = "aggregation to monthly MSC"

struct TimeMonthMSCAnomaly <: TimeAggregation end
purpose(::Type{TimeMonthMSCAnomaly}) = "aggregation to monthly MSC anomalies"

struct TimeNoDiff <: TimeAggregation end
purpose(::Type{TimeNoDiff}) = "aggregation without time differences"

struct TimeRandomYear <: TimeAggregation end
purpose(::Type{TimeRandomYear}) = "aggregation/slicing of a random year"

struct TimeShuffleYears <: TimeAggregation end
purpose(::Type{TimeShuffleYears}) = "aggregation/slicing/selection of shuffled years"

struct TimeSizedArray <: TimeAggregation end
purpose(::Type{TimeSizedArray}) = "aggregation to a sized array"

struct TimeYear <: TimeAggregation end
purpose(::Type{TimeYear}) = "aggregation to yearly time steps"

struct TimeYearAnomaly <: TimeAggregation end
purpose(::Type{TimeYearAnomaly}) = "aggregation to yearly anomalies"

