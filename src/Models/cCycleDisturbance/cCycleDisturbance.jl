export cCycleDisturbance

abstract type cCycleDisturbance <: LandEcosystem end

include("cCycleDisturbance_cFlow.jl")
include("cCycleDisturbance_WROASTED.jl")

@doc """
Disturb the carbon cycle pools

# Approaches:
 - cFlow: move all vegetation carbon pools except reserve to respective flow target when there is disturbance
 - WROASTED: move all vegetation carbon in excess of c_remain to cLitSlow in case of disturbance
 """
cCycleDisturbance
