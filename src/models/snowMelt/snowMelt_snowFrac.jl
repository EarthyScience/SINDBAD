export snowMelt_snowFrac

@bounds @describe @units @with_kw struct snowMelt_snowFrac{T1, T2} <: snowMelt
    melt_T::T1 = 3.0 | (0.01, 10.0) | "melt factor for temperature" | "mm/°C"
    melt_Rn::T2 = 2.0 | (0.01, 3.0) | "melt factor for radiation" | "mm/MJ/m²"
end

SnowFrac(snow) = snow > 0.0 ? 1.0 : 0.0


function compute(o::snowMelt_snowFrac, forcing, land, infotem)
    @unpack_snowMelt_snowFrac o

    @unpack_land begin
        # (rn, tair) = (Rn, Tair) ∈ forcing
        (Rn, Tair) ∈ forcing
        snow ∈ land.fluxes
        WBP ∈ land.diagnostics
        wSnow ∈ land.pools
    end

    potMelt = Tair * melt_T + max(0.0, Rn * melt_Rn)
    potMelt = Tair < 0.0 ? 0.0 : potMelt
    fracSnowMelt = min(1, (potMelt * SnowFrac(snow)) / sum(wSnow[:, 1]))
    snowMelt = fracSnowMelt * sum(wSnow[:, 1])
    WBP = WBP + snowMelt

    @pack_land begin
        (WBP, fracSnowMelt) ∋ land.diagnostics
        # (WBP, fracSnowMelt) => (wbp_n, snm_n) ∋ land.diagnostics
        snowMelt ∋ land.fluxes
        # snowMelt => melt_snow ∋ land.fluxes
    end

    return land
end

function update(o::snowMelt_snowFrac, forcing, land, infotem)
    @unpack_land begin
        (snowMelt, snow) ∈ land.fluxes
        wSnow ∈ land.pools
    end

    wSnow[1] = wSnow[1] + snow - snowMelt

    @pack_land begin
        wSnow ∋ land.pools
    end
    return land
end
