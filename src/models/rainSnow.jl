@with_kw struct rainSnow{type} <: EarthEcosystem
    Tair_thres::type = 0.5 # parametric
end

function run(o::rainSnow, forcing, out)
    @unpack_rainSnow o # repetition
    (; Tair, rain) = forcing
    snow = Tair_thres >= Tair ? 0.0 : rain
    rain = Tair_thres <= Tair ? 0.0 : rain
    precip = rain + snow
    return (; out..., snow, rain, precip)
end