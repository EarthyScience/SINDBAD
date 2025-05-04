# -------------------------------- time aggregator --------------------------------
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

abstract type SindbadTimeAggregator end
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


# -------------------------------- spatial subset --------------------------------
export Spaceid
export SpaceId
export SpaceID
export Spacelat
export Spacelatitude
export Spacelongitude
export Spacelon
export Spacesite
export SindbadSpatialSubsetType

abstract type SindbadSpatialSubsetType end
purpose(::Type{SindbadSpatialSubsetType}) = "Abstract type for spatial subsetting methods in SINDBAD"

struct Spaceid <: SindbadSpatialSubsetType end
purpose(::Type{Spaceid}) = "Use site ID for spatial subsetting"

struct SpaceId <: SindbadSpatialSubsetType end
purpose(::Type{SpaceId}) = "Use site ID (capitalized) for spatial subsetting"

struct SpaceID <: SindbadSpatialSubsetType end
purpose(::Type{SpaceID}) = "Use site ID (all caps) for spatial subsetting"

struct Spacelat <: SindbadSpatialSubsetType end
purpose(::Type{Spacelat}) = "Use latitude for spatial subsetting"

struct Spacelatitude <: SindbadSpatialSubsetType end
purpose(::Type{Spacelatitude}) = "Use full latitude for spatial subsetting"

struct Spacelongitude <: SindbadSpatialSubsetType end
purpose(::Type{Spacelongitude}) = "Use full longitude for spatial subsetting"

struct Spacelon <: SindbadSpatialSubsetType end
purpose(::Type{Spacelon}) = "Use longitude for spatial subsetting"

struct Spacesite <: SindbadSpatialSubsetType end
purpose(::Type{Spacesite}) = "Use site location for spatial subsetting"


# -------------------------------- forcing variable type --------------------------------
export ForcingWithTime
export ForcingWithoutTime
abstract type SindbadForcingType end
purpose(::Type{SindbadForcingType}) = "Abstract type for forcing variable types in SINDBAD"

struct ForcingWithTime <: SindbadForcingType end
purpose(::Type{ForcingWithTime}) = "Forcing variable with time dimension"

struct ForcingWithoutTime <: SindbadForcingType end
purpose(::Type{ForcingWithoutTime}) = "Forcing variable without time dimension"