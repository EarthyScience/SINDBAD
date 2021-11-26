
Base.@kwdef mutable struct snowMelt <: ecosystem
    Rn = Param(rand(4), units = u"MJ/m^2", bounds = (-50, 500), forcing = true)
    Tair = Param(rand(4), units = u"C", bounds = (-80, 60), forcing = true)
    melt_T = Param(3)
    melt_Rn = Param(2)
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
    snowMelt[Tair.<0] .= 0
    o.snowMelt = updateState(o.snowMelt, ustrip(snowMelt))
end

