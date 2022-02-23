@with_kw struct getStates_simple{type} <: TerEcosystem
    updateState::type = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function compute(o::getStates_simple, forcing, out)
    @unpack_getStates_simple o
    (; wSoil, wSnow) = out
    return (; out..., wSoil, wSnow)
end

export getStates_simple