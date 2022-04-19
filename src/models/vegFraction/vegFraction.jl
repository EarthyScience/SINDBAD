export vegFraction

abstract type vegFraction <: LandEcosystem end

include("vegFraction_constant.jl")
include("vegFraction_forcing.jl")
include("vegFraction_scaledEVI.jl")
include("vegFraction_scaledfAPAR.jl")
include("vegFraction_scaledLAI.jl")
include("vegFraction_scaledNDVI.jl")
include("vegFraction_scaledNIRv.jl")

@doc """
Fractional coverage of vegetation

# Approaches:
 - constant: sets the value of vegFraction as a constant
 - forcing: sets the value of land.states.vegFraction from the forcing in every time step
 - scaledEVI: sets the value of vegFraction by scaling the EVI value
 - scaledfAPAR: sets the value of vegFraction by scaling the fAPAR value
 - scaledLAI: sets the value of vegFraction by scaling the LAI value
 - scaledNDVI: sets the value of vegFraction by scaling the NDVI value
 - scaledNIRv: sets the value of vegFraction by scaling the NIRv value
"""
vegFraction