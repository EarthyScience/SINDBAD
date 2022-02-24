export rainSnow_Tair

@with_kw struct rainSnow_Tair{type} <: LandEcosystem
    Tair_thres::type = 0.5 # parametric
    para_a::type = 0.5
    para_b::type = 0.5
    Tair_thres_bounds = [0.1, 0.7] # parametric
end

function compute(o::rainSnow_Tair, forcing, out)
    @unpack_rainSnow_Tair o # repetition
    (; Tair, rain) = forcing
    snow = Tair < Tair_thres ? rain : 0.0
    rain = Tair >= Tair_thres ? rain : 0.0
    # rain = rain - snow
    precip = rain + snow
    return (; out..., Tair, snow, rain, precip)
end