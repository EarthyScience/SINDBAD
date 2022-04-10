@with_kw struct getStates_simple{T} <: getStates
    updateState::T = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function compute(o::getStates_simple, forcing, out, modelInfo)
    @unpack_getStates_simple o
    @unpack_land begin
        rain ∈ out.fluxes
    end

    WBP = rain

    @pack_land begin
        WBP ∋ out.diagnostics
    end
    return out
end

function update(o::getStates_simple, forcing, out, modelInfo)
    return out
end

export getStates_simple