export roSat_Bergstroem

@bounds @describe @units @with_kw struct roSat_Bergstroem{T1, T2} <: roSat
    β::T1 = 1.1 | (0.1, 5.0) | "shape parameter runoff-infiltration curve (Bergstroem)" | ""
    s_max::T2 = 1000 | (100, 5000) | "maximum storage for calculating relative wetness" | "mm"
end

function compute(o::roSat_Bergstroem, forcing, out, info)
    @unpack_roSat_Bergstroem o
    (; wSoil) = out.states
    (; WBP) = out.diagnostics
    # fracRoSat = clamp((sum(wSoil[:,1]) / s_max)^β, 0, 1)
    fracRoSat = 0.2
    roSat = fracRoSat * WBP
    WBP = WBP - roSat
    out = (; out..., diagnostics = (; out.diagnostics..., WBP, fracRoSat))
    out = (; out..., fluxes = (; out.fluxes..., roSat))
    return out
end

function update(o::roSat_Bergstroem, forcing, out, info)
    (; WBP) = out.diagnostics
    (; wSoil) = out.states
    wSoil[1] = wSoil[1] + WBP
    WBP = 0.0
    out = (; out..., states = (; out.states..., wSoil))
    out = (; out..., diagnostics = (; out.diagnostics..., WBP))
    return out
end
