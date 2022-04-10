export roSat_Bergstroem

@bounds @describe @units @with_kw struct roSat_Bergstroem{T1, T2} <: roSat
    β::T1 = 1.1 | (0.1, 5.0) | "shape parameter runoff-infiltration curve (Bergstroem)" | ""
    s_max::T2 = 1000.0 | (100.0, 5000.0) | "maximum storage for calculating relative wetness" | "mm"
end

function compute(o::roSat_Bergstroem, forcing, out, modelInfo)
    @unpack_roSat_Bergstroem o
    @unpack_land begin
        wSoil ∈ out.pools
        WBP ∈ out.diagnostics
    end
    # fracRoSat = clamp((sum(wSoil[:,1]) / s_max)^β, 0, 1)
    fracRoSat = 0.2
    roSat = fracRoSat * WBP
    WBP = WBP - roSat
    @pack_land begin
        roSat ∋ out.fluxes
        (WBP, fracRoSat) ∋ out.diagnostics
    end

    return out
end

function update(o::roSat_Bergstroem, forcing, out, modelInfo)
    @unpack_land begin
        wSoil ∈ out.pools
        WBP ∈ out.diagnostics
    end

    wSoil[1] = wSoil[1] + WBP
    WBP = 0.0

    @pack_land begin
        wSoil ∋ out.pools
        WBP ∋ out.diagnostics
    end

    return out
end
