export autoRespiration

abstract type autoRespiration <: LandEcosystem end

include("autoRespiration_none.jl")
include("autoRespiration_Thornley2000A.jl")
include("autoRespiration_Thornley2000B.jl")
include("autoRespiration_Thornley2000C.jl")

@doc """
Determine autotrophic respiration (RA) based on the growth and maintenance respiration components.

# Approaches:
 - none: No RA. Sets the C respiration flux from all vegetation pools to zero.
 - Thornley2000A: Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL A - maintenance respiration is given priority [check Fig.1 of the paper].
 - Thornley2000B: Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL B - growth respiration is given priority (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]
 - Thornley2000C: Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL C - growth, degradation & resynthesis view of respiration (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]
"""
autoRespiration
