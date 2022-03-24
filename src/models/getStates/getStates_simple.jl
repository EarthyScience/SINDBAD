@with_kw struct getStates_simple{T} <: getStates
    updateState::T = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function compute(o::getStates_simple, forcing, diagflux, states, info)
    @unpack_getStates_simple o
    (; rain) = diagflux
    WBP = rain
    return (; diagflux..., WBP)
end

function update(o::getStates_simple, forcing, diagflux, states, info)
    return (diagflux, states)
end

export getStates_simple