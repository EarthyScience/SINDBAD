export rainSnow

abstract type rainSnow <: LandEcosystem end

include("rainSnow_forcing.jl")
include("rainSnow_Tair.jl")
include("rainSnow_rain.jl")

@doc """
Set rain and snow to fe.rainsnow.

# Approaches:
 - forcing: stores the time series of rainfall and snowfall from forcing & scale snowfall if snowfall_scalar parameter is optimized
 - f_airT: separates the rain & snow based on temperature threshold
 - rain: sets all precip as rain and snow as zero
"""
rainSnow
