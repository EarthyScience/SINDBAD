export deriveVariables

abstract type deriveVariables <: LandEcosystem end

include("deriveVariables_simple.jl")

@doc """
Derive extra variables

# Approaches:
 - simple: simply add variables on the go
"""
deriveVariables
