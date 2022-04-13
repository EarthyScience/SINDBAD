export aRespiration
"""
Determine growth and maintenance respiration -> npp

# Approaches:
 - none: sets the outflow from all vegetation pools to zeros
 - Thornley2000A: Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL A - maintenance respiration is given priority [check Fig.1 of the paper].
 - Thornley2000B: Precomputations to estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL B - growth respiration is given priority (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]
 - Thornley2000C: Precomputations to estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell (2000): MODEL C - growth, degradation & resynthesis view of respiration (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient]
"""
abstract type aRespiration <: LandEcosystem end
include("aRespiration_none.jl")
include("aRespiration_Thornley2000A.jl")
include("aRespiration_Thornley2000B.jl")
include("aRespiration_Thornley2000C.jl")
