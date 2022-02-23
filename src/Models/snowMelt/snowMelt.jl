export snowMelt

abstract type snowMelt <: LandEcosystem end

include("snowMelt_Tair.jl")
include("snowMelt_TairRn.jl")

@doc """
Calculate snowmelt and update s.w.wsnow

# Approaches:
 - Tair: computes the snow melt term as function of air temperature.
 - TairRn: snowmelt based on temperature & net radiation on days with Tair > 0.0°C.
"""
snowMelt