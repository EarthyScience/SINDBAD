export sublimation

abstract type sublimation <: LandEcosystem end

include("sublimation_GLEAM.jl")
include("sublimation_none.jl")

@doc """
Calculate sublimation and update snow water equivalent

# Approaches:
 - GLEAM: precomputes the Priestley-Taylor term for sublimation following GLEAM. computes sublimation following GLEAM
 - none: sets the snow sublimation to zero
"""
sublimation