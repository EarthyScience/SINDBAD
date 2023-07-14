export gppVPD

abstract type gppVPD <: LandEcosystem end

include("gppVPD_expco2.jl")
include("gppVPD_Maekelae2008.jl")
include("gppVPD_MOD17.jl")
include("gppVPD_none.jl")
include("gppVPD_PRELES.jl")

@doc """
Vpd effect

# Approaches:
 - expco2: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect
 - Maekelae2008: VPD stress on gpp_potential based on Maekelae2008 [eqn 5]
 - MOD17: VPD stress on gpp_potential based on MOD17 model
 - none: sets the VPD stress on gpp_potential to one (no stress)
 - PRELES: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect based on PRELES model
"""
gppVPD
