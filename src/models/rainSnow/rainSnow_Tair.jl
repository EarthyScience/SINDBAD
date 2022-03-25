export rainSnow_Tair

@bounds @describe @units @with_kw struct rainSnow_Tair{T} <: rainSnow
    Tair_thres::T = 0.5 | (-5.0, 5.0) | "Temperature threshold for rain-snow separation" | "°C"
end

function compute(o::rainSnow_Tair, forcing, out, info)
    @unpack_rainSnow_Tair o
    (; Tair, rain) = forcing
    snow = Tair < Tair_thres ? rain : 0.0
    rain = Tair >= Tair_thres ? rain : 0.0
    precip = rain + snow
    out = (; out..., fluxes = (; out.fluxes..., rain, snow, precip))
    return out
end

function update(o::rainSnow_Tair, forcing, out, info)
    return out
end
