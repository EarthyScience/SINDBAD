export snowMelt_snowFrac

@with_kw struct snowMelt_snowFrac{type} <: TerEcosystem
    melt_T::type = 3.0 # parametric type
    melt_Rn::type = 2.0
end

SnowFrac(snow) = snow > 0.0 ? 1.0 : 0.0

function compute(o::snowMelt_snowFrac, forcing, out)
    @unpack_snowMelt_snowFrac o
    (; Rn, Tair) = forcing
    (; snow, wSnow) = out

    potMelt = Tair * melt_T + maximum([0.0, Rn * melt_Rn])
    potMelt = Tair < 0.0 ? 0.0 : potMelt
    fracSnowMelt = minimum([1, (potMelt * SnowFrac(snow)) / wSnow])
    return (; out..., potMelt, fracSnowMelt)
end