export rainSnow

abstract type rainSnow <: LandEcosystem end

include("rainSnow_forcing.jl")
include("rainSnow_Tair.jl")

@doc """
Set rain and snow to fe.rainsnow.

# Approaches:
 - forcing: stores the time series of rainfall and snowfall from forcing & scale snowfall if SF_scale parameter is optimized
 - Tair: separates the rain & snow based on temperature threshold
"""
rainSnow