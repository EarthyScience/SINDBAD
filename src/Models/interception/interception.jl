export interception

abstract type interception <: LandEcosystem end

include("interception_fAPAR.jl")
include("interception_Miralles2010.jl")
include("interception_none.jl")
include("interception_vegFraction.jl")

@doc """
Interception evaporation

# Approaches:
 - fAPAR: computes canopy interception evaporation as a fraction of fAPAR
 - Miralles2010: computes canopy interception evaporation according to the Gash model
 - none: sets the interception evaporation to zero
 - vegFraction: computes canopy interception evaporation as a fraction of vegetation cover
"""
interception