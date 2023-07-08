
export temporal_aggregation

function do_the_mean(dat, ::Val{:mean})
    return mean(dat)
end

function do_the_mean(dat, ::Val{:nanmean})
    return nanmean(dat)
end

function temporal_aggregation(y, yσ, ŷ, cost_option, ::Val{:mean})
    ŷ = do_the_mean(ŷ, cost_option.temporalAggrFunc)
    if cost_option.temporalAggrObs
        y = do_the_mean(y, cost_option.temporalAggrFunc)
        yσ = do_the_mean(yσ, cost_option.temporalAggrFunc)
    end
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:day})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, cost_option, ::Val{:dayAnomaly})
    μ_ŷ = do_the_mean(ŷ, cost_option.temporalAggrFunc)
    ŷ .= ŷ .- μ_ŷ
    if cost_option.temporalAggrObs
        μ_y = do_the_mean(y, cost_option.temporalAggrFunc)
        y .= y .- μ_y
    end
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:dayMSC})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:dayMSCAnomaly})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:dayIAV})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:month})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:monthAnomaly})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:monthMSC})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:monthMSCAnomaly})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:monthIAV})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:year})
    return y, yσ, ŷ
end

function temporal_aggregation(y, yσ, ŷ, _, ::Val{:yearAnomaly})
    return y, yσ, ŷ
end
