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

struct TimeAllYears <: SindbadTimeAggregator end
struct TimeArray <: SindbadTimeAggregator end
struct TimeHour <: SindbadTimeAggregator end
struct TimeHourAnomaly <: SindbadTimeAggregator end
struct TimeHourDayMean <: SindbadTimeAggregator end
struct TimeDay <: SindbadTimeAggregator end
struct TimeDayAnomaly <: SindbadTimeAggregator end
struct TimeDayIAV <: SindbadTimeAggregator end
struct TimeDayMSC <: SindbadTimeAggregator end
struct TimeDayMSCAnomaly <: SindbadTimeAggregator end
struct TimeDiff <: SindbadTimeAggregator end
struct TimeFirstYear <: SindbadTimeAggregator end
struct TimeIndexed <: SindbadTimeAggregator end
struct TimeMean <: SindbadTimeAggregator end
struct TimeMonth <: SindbadTimeAggregator end
struct TimeMonthAnomaly <: SindbadTimeAggregator end
struct TimeMonthIAV <: SindbadTimeAggregator end
struct TimeMonthMSC <: SindbadTimeAggregator end
struct TimeMonthMSCAnomaly <: SindbadTimeAggregator end
struct TimeNoDiff <: SindbadTimeAggregator end
struct TimeRandomYear <: SindbadTimeAggregator end
struct TimeShuffleYears <: SindbadTimeAggregator end
struct TimeSizedArray <: SindbadTimeAggregator end
struct TimeYear <: SindbadTimeAggregator end
struct TimeYearAnomaly <: SindbadTimeAggregator end


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
struct Spaceid <: SindbadSpatialSubsetType end
struct SpaceId <: SindbadSpatialSubsetType end
struct SpaceID <: SindbadSpatialSubsetType end
struct Spacelat <: SindbadSpatialSubsetType end
struct Spacelatitude <: SindbadSpatialSubsetType end
struct Spacelongitude <: SindbadSpatialSubsetType end
struct Spacelon <: SindbadSpatialSubsetType end
struct Spacesite <: SindbadSpatialSubsetType end


# -------------------------------- forcing variable type --------------------------------
export ForcingWithTime
export ForcingWithoutTime
abstract type SindbadForcingType end
struct ForcingWithTime <: SindbadForcingType end
struct ForcingWithoutTime <: SindbadForcingType end