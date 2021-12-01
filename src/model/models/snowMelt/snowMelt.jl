
Base.@kwdef mutable struct snowMelt <: ecosystem
    Rn = Forcing(rand(4); units = u"MJ/m^2", bounds = (-50, 500))
    Tair = Forcing(rand(4); units = u"C", bounds = (-80, 60)) # TODO, change to kelvin [for physical/computational correctness] i.e. uconvert.(u"K", u"°C" .* rand(10))
    melt_T = Param(3, units = u"1/C", bounds = (0.1, 10))
    melt_Rn = Param(2, units = u"m^2/MJ", bounds = (0.1, 10))
    snowMeltOut = Param(missing)
end

"""
    run!(o::snowMelt)

Computes the potential snow melt based on temperature and net radiation
on days with Tair > 0degC.
"""
function run!(o::snowMelt)
    Rn, Tair, melt_T, melt_Rn, snowMelt = withunits(Model(o))
    snowMelt = Tair .* melt_T .+ maximum.(tuple.(0, Rn .* melt_Rn))
    snowMelt[Tair.<0u"C"] .*= 0
    o.snowMeltOut = updateState(o.snowMeltOut, ustrip(snowMelt))
end

