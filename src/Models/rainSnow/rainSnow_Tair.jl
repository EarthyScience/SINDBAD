export rainSnow_Tair

@with_kw struct rainSnow_Tair{type} <: LandEcosystem
    Tair_thres::type = 0.5
end

function compute(o::rainSnow_Tair, forcing, out)
    @unpack_rainSnow_Tair o
    (; Tair, rain) = forcing
    snow = Tair < Tair_thres ? rain : 0.0
    rain = Tair >= Tair_thres ? rain : 0.0
    # rain = rain - snow
    precip = rain + snow
    return (; out..., Tair, snow, rain, precip)
end