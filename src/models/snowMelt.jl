@with_kw struct snowMelt{type} <: EarthEcosystem
    melt_T::type = 3.0 # parametric type
    melt_Rn::type = 2.0
    wSnow::type = 0.0
end

SnowFrac(snow) = snow > 0.0 ? 1.0 : 0.0

function run(o::snowMelt, forcing, out)
    @unpack_snowMelt o
    (; Rn, Tair) = forcing
    (; snow, wSnow) = out

    potMelt = Tair * melt_T + maximum([0.0, Rn * melt_Rn])
    potMelt = Tair < 0.0 ? 0.0 : potMelt
    FracSnowMelt = minimum([1, (potMelt * SnowFrac(snow)) / wSnow])
    return (; out..., potMelt, FracSnowMelt, wSnow)
end