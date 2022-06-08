@with_kw struct rainSnow{type} <: TerEcosystem
export rainSnow_Tair

@with_kw struct rainSnow_Tair{type} <: LandEcosystem
    Tair_thres::type = 0.5
end

function run(o::rainSnow, forcing, out)
    @unpack_rainSnow o # repetition
    (; Tair, Rain) = forcing
    # if Tair < Tair_thres
    #     snow = rain
    #     rain = 0.0
    # else
    #     snow = 0.0
    # end
    snow = Tair < Tair_thres ? Rain : 0.0
    rain = Tair >= Tair_thres ? Rain : 0.0
function compute(o::rainSnow_Tair, forcing, out)
    @unpack_rainSnow_Tair o
    (; Tair, rain) = forcing
    snow = Tair < Tair_thres ? rain : 0.0
    rain = Tair >= Tair_thres ? rain : 0.0
    # rain = rain - snow
    precip = rain + snow
    return (; out..., Tair, snow, rain, precip)
end
