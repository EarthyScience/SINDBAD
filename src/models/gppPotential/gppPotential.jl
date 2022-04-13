export gppPotential
"""
Maximum instantaneous radiation use efficiency

# Approaches:
 - Monteith: set the potential GPP based on radiation use efficiency
"""
abstract type gppPotential <: LandEcosystem end
include("gppPotential_Monteith.jl")
