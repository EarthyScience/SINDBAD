export rainSnow_Tair

@with_kw struct rainSnow_Tair{T} <: rainSnow
    Tair_thres::T = 0.5
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
