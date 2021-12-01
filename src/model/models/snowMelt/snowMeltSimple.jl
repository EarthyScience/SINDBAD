
Base.@kwdef mutable struct snowMeltSimple <: ecosystem
    Tair = Forcing(rand(4); units = u"C", bounds = (-80, 60))
    melt_rate = Param(1, units = u"mm/C", bounds = (0.1, 10))
    nStepsDay = Param(10, units = u"1/d")
    Tterm = Param(missing, units = u"mm/d")
end

"""
    run!(o::snowMeltSimple)

Computes the snow melt term as a function of Tair
"""
function run!(o::snowMeltSimple)
    Tair, melt_rate, nStepsDay, Tterm = withunits(Model(o))
    Tterm = melt_rate .* nStepsDay .* Tair
    Tterm = [maximum([Tterm[i], 0u"mm/d"]) for i in 1:length(Tterm)]
    o.Tterm = updateState(o.Tterm, ustrip(Tterm))
end
