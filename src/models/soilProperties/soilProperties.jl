export soilProperties
"""
Soil properties (hydraulic properties)

# Approaches:
 - Saxton1986: assigns the soil hydraulic properties based on Saxton; 1986 to land.soilProperties.p_
 - Saxton2006: assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.p_
"""
abstract type soilProperties <: LandEcosystem end
include("soilProperties_Saxton1986.jl")
include("soilProperties_Saxton2006.jl")
