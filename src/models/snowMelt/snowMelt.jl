export snowMelt
"""
Calculate snowmelt and update s.w.wsnow

# Approaches:
 - simple: precomputes the snow melt term as function of forcing.Tair. computes the snow melt term as function of forcing.Tair
 - TRn: precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0°C. precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0 °C
"""
abstract type snowMelt <: LandEcosystem end
include("snowMelt_simple.jl")
include("snowMelt_TRn.jl")
