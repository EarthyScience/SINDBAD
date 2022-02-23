export rainSnow_simpleorwhatever

@with_kw struct rainSnow_simpleorwhatever{type} <: TerEcosystem
    Tair_thres::type = 0.5 # parametric
    para_a::type = 0.5
    para_b::type = 0.5
    Tair_thres_bounds = [0.1, 0.7] # parametric
end

function compute(o::rainSnow_simpleorwhatever, forcing, out)
    @unpack_rainSnow_simpleorwhatever o # repetition
    (; Tair, rain) = forcing
    # if Tair < Tair_thres
    #     snow = rain
    #     rain = 0.0
    # else
    #     snow = 0.0
    # end
    snow = Tair > Tair_thres ? rain : 0.0
    rain = Tair <= Tair_thres ? rain : 0.0
    # rain = rain - snow
    precip = rain + snow
    return (; out..., Tair, snow, rain, precip)
end