@with_kw struct getStates_simple{T} <: getStates
    updateState::T = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function compute(o::getStates_simple, forcing, land, infotem)
    @unpack_getStates_simple o
    @unpack_land begin
        rain ∈ land.fluxes
    end

    WBP = rain

    @pack_land begin
        WBP ∋ land.diagnostics
    end
    return land
end

function update(o::getStates_simple, forcing, land, infotem)
    return land
end

export getStates_simple