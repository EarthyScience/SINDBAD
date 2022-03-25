export snowMelt_snowFrac

@bounds @describe @units @with_kw struct snowMelt_snowFrac{T1, T2} <: snowMelt
    melt_T::T1 = 3.0 | (0.01, 10.0) | "melt factor for temperature" | "mm/°C"
    melt_Rn::T2 = 2.0 | (0.01, 3.0) | "melt factor for radiation" | "mm/MJ/m²"
end

SnowFrac(snow) = snow > 0.0 ? 1.0 : 0.0

function compute(o::snowMelt_snowFrac, forcing, out, info)
    @unpack_snowMelt_snowFrac o
    (; Rn, Tair) = forcing
    (; snow) = out.fluxes
    (; WBP) = out.diagnostics
    (; wSnow) = out.states

    potMelt = Tair * melt_T + max(0.0, Rn * melt_Rn)
    potMelt = Tair < 0.0 ? 0.0 : potMelt
    fracSnowMelt = min(1, (potMelt * SnowFrac(snow)) / sum(wSnow[:, 1]))
    snowMelt = fracSnowMelt * sum(wSnow[:, 1])
    WBP = WBP + snowMelt
    out = (; out..., diagnostics = (; out.diagnostics..., WBP, fracSnowMelt))
    out = (; out..., fluxes = (; out.fluxes..., snowMelt))
    return out
end

function update(o::snowMelt_snowFrac, forcing, out, info)
    (; snowMelt, snow) = out.fluxes
    (; wSnow) = out.states
    wSnow[1] = wSnow[1] + snow - snowMelt
    out = (; out..., states = (; out.states..., wSnow))
    return out
end
