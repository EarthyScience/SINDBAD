
export SindbadTimeType
abstract type SindbadTimeType <: SindbadType end
purpose(::Type{SindbadTimeType}) = "Abstract type for implementing time subset and aggregation types in SINDBAD"

# ------------------------- time aggregator ------------------------------------------------------------
export SindbadTimeAggregator
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
struct TimeAggregator{I,aggr_func} <: SindbadTimeType
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


abstract type SindbadTimeAggregator <: SindbadTimeType end
purpose(::Type{SindbadTimeAggregator}) = "Abstract type for time aggregation methods in SINDBAD"

struct TimeAllYears <: SindbadTimeAggregator end
purpose(::Type{TimeAllYears}) = "aggregation/slicing to include all years"

struct TimeArray <: SindbadTimeAggregator end
purpose(::Type{TimeArray}) = "use array-based time aggregation"

struct TimeHour <: SindbadTimeAggregator end
purpose(::Type{TimeHour}) = "aggregation to hourly time steps"

struct TimeHourAnomaly <: SindbadTimeAggregator end
purpose(::Type{TimeHourAnomaly}) = "aggregation to hourly anomalies"

struct TimeHourDayMean <: SindbadTimeAggregator end
purpose(::Type{TimeHourDayMean}) = "aggregation to mean of hourly data over days"

struct TimeDay <: SindbadTimeAggregator end
purpose(::Type{TimeDay}) = "aggregation to daily time steps"

struct TimeDayAnomaly <: SindbadTimeAggregator end
purpose(::Type{TimeDayAnomaly}) = "aggregation to daily anomalies"

struct TimeDayIAV <: SindbadTimeAggregator end
purpose(::Type{TimeDayIAV}) = "aggregation to daily IAV"

struct TimeDayMSC <: SindbadTimeAggregator end
purpose(::Type{TimeDayMSC}) = "aggregation to daily MSC"

struct TimeDayMSCAnomaly <: SindbadTimeAggregator end
purpose(::Type{TimeDayMSCAnomaly}) = "aggregation to daily MSC anomalies"

struct TimeDiff <: SindbadTimeAggregator end
purpose(::Type{TimeDiff}) = "aggregation to time differences, e.g. monthly anomalies"

struct TimeFirstYear <: SindbadTimeAggregator end
purpose(::Type{TimeFirstYear}) = "aggregation/slicing of the first year"

struct TimeIndexed <: SindbadTimeAggregator end
purpose(::Type{TimeIndexed}) = "aggregation using time indices, e.g., TimeFirstYear"

struct TimeMean <: SindbadTimeAggregator end
purpose(::Type{TimeMean}) = "aggregation to mean over all time steps"

struct TimeMonth <: SindbadTimeAggregator end
purpose(::Type{TimeMonth}) = "aggregation to monthly time steps"

struct TimeMonthAnomaly <: SindbadTimeAggregator end
purpose(::Type{TimeMonthAnomaly}) = "aggregation to monthly anomalies"

struct TimeMonthIAV <: SindbadTimeAggregator end
purpose(::Type{TimeMonthIAV}) = "aggregation to monthly IAV"

struct TimeMonthMSC <: SindbadTimeAggregator end
purpose(::Type{TimeMonthMSC}) = "aggregation to monthly MSC"

struct TimeMonthMSCAnomaly <: SindbadTimeAggregator end
purpose(::Type{TimeMonthMSCAnomaly}) = "aggregation to monthly MSC anomalies"

struct TimeNoDiff <: SindbadTimeAggregator end
purpose(::Type{TimeNoDiff}) = "aggregation without time differences"

struct TimeRandomYear <: SindbadTimeAggregator end
purpose(::Type{TimeRandomYear}) = "aggregation/slicing of a random year"

struct TimeShuffleYears <: SindbadTimeAggregator end
purpose(::Type{TimeShuffleYears}) = "aggregation/slicing/selection of shuffled years"

struct TimeSizedArray <: SindbadTimeAggregator end
purpose(::Type{TimeSizedArray}) = "aggregation to a sized array"

struct TimeYear <: SindbadTimeAggregator end
purpose(::Type{TimeYear}) = "aggregation to yearly time steps"

struct TimeYearAnomaly <: SindbadTimeAggregator end
purpose(::Type{TimeYearAnomaly}) = "aggregation to yearly anomalies"

