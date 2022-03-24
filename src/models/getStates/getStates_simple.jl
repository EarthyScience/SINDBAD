@with_kw struct getStates_simple{T} <: getStates
    updateState::T = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function compute(o::getStates_simple, forcing, out, info)
    @unpack_getStates_simple o
    (; rain) = out.fluxes
    WBP = rain
    out = (; out..., diagnostics = (; out.diagnostics..., WBP))
    return out
end

function update(o::getStates_simple, forcing, out, info)
    return out
end

export getStates_simple