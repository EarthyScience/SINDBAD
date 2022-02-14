@with_kw struct snowMelt{T} <: EarthEcosystem
    melt_T::T = 3.0 # parametric type
    melt_Rn::T = 2.0
end

function run(o::snowMelt, forcing, out)
    @unpack_snowMelt o
    (; Rn, Tair), snow = forcing, out.snow
    potMelt = Tair * melt_T + maximum([0.0, Rn * melt_Rn])
    potMelt = Tair < 0.0 ? 0.0 : potMelt
    wSnow = snow - minimum([snow, potMelt * SnowFrac(snow)])
    return (; out..., potMelt, wSnow)
end