Base.@kwdef mutable struct rainSnowWind <: ecosystem
    Rain = Param(rand(4), units = u"mm/d", bounds = (0, 100), forcing = true)
    Snow = Param(missing, units = u"mm/d")
    Tair = Param(rand(4), units = u"°C", bounds = (-80, 60), forcing = true)
    Tair_thres = Param(0.5, units = u"°C", bounds = (-5, 5))
    precip = Param(missing, units = "mm/d")
end

"""
    run!(o::rainSnow)

Stores rainfall and estimated snowfall from forcing (input variables).
"""
function run!(o::rainSnowWind)
    rain, snow, Tair, Tair_thres = withunits(Model(o)) # without units, here! and done for second step.
    snow = copy(rain)
    snow[Tair_thres.>=Tair] .*= 0
    rain[Tair_thres.<=Tair] .*= 0
    precip = snow .+ rain
    # update parameters
    o.Snow = updateState(o.Snow, ustrip(snow))
    o.Rain = updateState(o.Rain, ustrip(rain))
    o.precip = updateState(o.precip, ustrip(precip))
end