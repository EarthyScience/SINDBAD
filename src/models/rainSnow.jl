@with_kw struct rainSnow{T} <: EarthEcosystem
    Tair_thres::T = 0.5 # parametric
end

SnowFrac(snow) = snow > 0.0 ? 1.0 : 0.0

function run(o::rainSnow, forcing, out)
    @unpack_rainSnow o # repetition
    (; Tair, rain) = forcing
    snow = Tair_thres >= Tair ? 0.0 : rain
    rain = Tair_thres <= Tair ? 0.0 : rain
    precip = rain + snow
    return (; out..., snow, rain, precip)
end