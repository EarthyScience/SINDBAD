export getTimeAggregatorTypeInstance
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

struct TimeAllYears end
struct TimeArray end
struct TimeDay end
struct TimeDayAnomaly end
struct TimeDayIAV end
struct TimeDayMSC end
struct TimeDayMSCAnomaly end
struct TimeDiff end
struct TimeFirstYear end
struct TimeIndexed end
struct TimeMean end
struct TimeMonth end
struct TimeMonthAnomaly end
struct TimeMonthIAV end
struct TimeMonthMSC end
struct TimeMonthMSCAnomaly end
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
    if aggr == "mean"
        return TimeMean()
    elseif aggr == "day"
        return TimeDay()
    elseif aggr == "day_anomaly"
        return TimeDayAnomaly()
    elseif aggr == "day_iav"
        return TimeDayIAV()
    elseif aggr == "day_msc"
        return TimeDayMSC()
    elseif aggr == "day_msc_anomaly"
        return TimeDayMSCAnomaly()
    elseif aggr == "month"
        return TimeMonth()
    elseif aggr == "month_anomaly"
        return TimeMonthAnomaly()
    elseif aggr == "month_iav"
        return TimeMonthIAV()
    elseif aggr == "month_msc"
        return TimeMonthMSC()
    elseif aggr == "month_msc_anomaly"
        return TimeMonthMSCAnomaly()
    elseif aggr == "year"
        return TimeYear()
    elseif aggr == "year_anomaly"
        return TimeYearAnomaly()
    elseif aggr == "all_years"
        return TimeAllYears()
    elseif aggr == "first_year"
        return TimeFirstYear()
    elseif aggr == "random_year"
        return TimeRandomYear()
    elseif aggr == "shuffle_years"
        return TimeShuffleYears()
    else
        return TimeDay()
    end
end