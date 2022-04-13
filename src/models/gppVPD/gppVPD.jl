export gppVPD
"""
Vpd effect

# Approaches:
 - expco2: please adjust ;) calculate the VPD stress on gppPot based on Maekelae2008 & PRELES model
 - Maekelae2008: calculate the VPD stress on gppPot based on Maekelae2008 [eqn 5]
 - MOD17: calculate the VPD stress on gppPot based on MOD17 model
 - none: set the VPD stress on gppPot to ones (no stress)
 - PRELES: please adjust ;) calculate the VPD stress on gppPot based on Maekelae2008 & PRELES model
"""
abstract type gppVPD <: LandEcosystem end
include("gppVPD_expco2.jl")
include("gppVPD_Maekelae2008.jl")
include("gppVPD_MOD17.jl")
include("gppVPD_none.jl")
include("gppVPD_PRELES.jl")
