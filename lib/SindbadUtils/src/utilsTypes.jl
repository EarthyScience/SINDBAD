# -------------------------------- time aggregator --------------------------------
export getTimeAggregatorTypeInstance
export SindbadTimeAggregator
export TimeAllYears
export TimeArray
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



function getTimeAggregatorTypeInstance(aggr::Symbol)
    return getTimeAggregatorTypeInstance(string(aggr))
end

function getTimeAggregatorTypeInstance(aggr::String)
    uc_first = toUpperCaseFirst(aggr, "Time")
    return getfield(SindbadUtils, uc_first)()
end

# -------------------------------- spatial subset --------------------------------
export Spaceid
export SpaceId
export SpaceID
export Spacelat
export Spacelatitude
export Spacelongitude
export Spacelon
export Spacesite

struct Spaceid end
struct SpaceId end
struct SpaceID end
struct Spacelat end
struct Spacelatitude end
struct Spacelongitude end
struct Spacelon end
struct Spacesite end


# -------------------------------- forcing variable type --------------------------------
export ForcingWithTime
export ForcingWithoutTime
abstract type ForcingTimeSeries end
struct ForcingWithTime <: ForcingTimeSeries end
struct ForcingWithoutTime <: ForcingTimeSeries end