export rainSnow_Tair

@with_kw struct rainSnow_Tair{T} <: rainSnow
    Tair_thres::T = 0.5
end

function compute(o::rainSnow_Tair, forcing, diagflux, states, info)
    @unpack_rainSnow_Tair o
    (; Tair, rain) = forcing
    snow = Tair < Tair_thres ? rain : 0.0
    rain = Tair >= Tair_thres ? rain : 0.0
    # rain = rain - snow
    precip = rain + snow
    return (; diagflux..., snow, rain, precip)
end

function update(o::rainSnow_Tair, forcing, diagflux, states, info)
    return (diagflux, states)
end
