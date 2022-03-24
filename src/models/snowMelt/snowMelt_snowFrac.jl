export snowMelt_snowFrac

@bounds @describe @units @with_kw struct snowMelt_snowFrac{T1, T2} <: snowMelt
    melt_T::T1 = 3.0 | (0.051, 10.0) | "" | ""
    melt_Rn::T2 = 2.0 | (0.01, 3.0) | "" | ""
end

SnowFrac(snow) = snow > 0.0 ? 1.0 : 0.0

function compute(o::snowMelt_snowFrac, forcing, diagflux, states, info)
    @unpack_snowMelt_snowFrac o
    (; Rn, Tair) = forcing
    (; snow, WBP) = diagflux
    (; wSnow) = states

    potMelt = Tair * melt_T + max(0.0, Rn * melt_Rn)
    potMelt = Tair < 0.0 ? 0.0 : potMelt
    fracSnowMelt = min(1, (potMelt * SnowFrac(snow)) / sum(wSnow[:, 1]))
    snowMelt = fracSnowMelt * sum(wSnow[:, 1])
    WBP = WBP + snowMelt
    return (; diagflux..., potMelt, snowMelt, fracSnowMelt)
end

function update(o::snowMelt_snowFrac, forcing, diagflux, states, info)
    (; fracSnowMelt, snow) = diagflux
    (; wSnow) = states
    snowMelt = fracSnowMelt * sum(wSnow[:, 1])
    @show "update", fracSnowMelt, snowMelt, wSnow[1]
    wSnow[1] = wSnow[1] + snow - snowMelt
    return (; diagflux..., snowMelt; states..., wSnow)
end
