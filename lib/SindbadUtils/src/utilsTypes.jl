# -------------------------------- time aggregator --------------------------------
export getTimeAggregatorTypeInstance
export TimeAllYears
export TimeArray
export TimeDay
export TimeDayAnomaly
export TimeDayIav
export TimeDayMsc
export TimeDayMscAnomaly
export TimeDiff
export TimeFirstYear
export TimeIndexed
export TimeMean
export TimeMonth
export TimeMonthAnomaly
export TimeMonthIav
export TimeMonthMsc
export TimeMonthMscAnomaly
export TimeNoDiff
export TimeRandomYear
export TimeShuffleYears
export TimeSizedArray
export TimeYear
export TimeYearAnomaly

struct TimeAllYears end
struct TimeArray end
struct TimeDay end
struct TimeDayAnomaly end
struct TimeDayIav end
struct TimeDayMsc end
struct TimeDayMscAnomaly end
struct TimeDiff end
struct TimeFirstYear end
struct TimeIndexed end
struct TimeMean end
struct TimeMonth end
struct TimeMonthAnomaly end
struct TimeMonthIav end
struct TimeMonthMsc end
struct TimeMonthMscAnomaly end
struct TimeNoDiff end
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

