@with_kw struct getStates_simple{type} <: LandEcosystem
    updateState::type = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function compute(o::getStates_simple, forcing, out)
    @unpack_getStates_simple o
    (; rain) = out
    WBP = rain
    return (; out..., WBP)
end

export getStates_simple