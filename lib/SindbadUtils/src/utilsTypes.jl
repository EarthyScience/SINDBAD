# -------------------------------- time aggregator --------------------------------
export getTimeAggregatorTypeInstance
export TimeAggregatorTypes
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

abstract type TimeAggregatorTypes end

struct TimeAllYears end
struct TimeArray end
struct TimeDay end
struct TimeDayAnomaly end
struct TimeDayIAV end
struct TimeDayMSC end
struct TimeDayMSCAnomaly end
struct TimeDiff <: TimeAggregatorTypes end
struct TimeFirstYear end
struct TimeIndexed <: TimeAggregatorTypes end
struct TimeMean end
struct TimeMonth end
struct TimeMonthAnomaly end
struct TimeMonthIAV end
struct TimeMonthMSC end
struct TimeMonthMSCAnomaly end
struct TimeNoDiff <: TimeAggregatorTypes end
struct TimeRandomYear end
struct TimeShuffleYears end
struct TimeSizedArray end
struct TimeYear end
struct TimeYearAnomaly end



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