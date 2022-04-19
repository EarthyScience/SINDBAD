export soilWBase

abstract type soilWBase <: LandEcosystem end

include("soilWBase_smax1Layer.jl")
include("soilWBase_smax2fPFT.jl")
include("soilWBase_smax2fRD4.jl")
include("soilWBase_smax2Layer.jl")
include("soilWBase_uniform.jl")

@doc """
Distribution of soil hydraulic properties over depth

# Approaches:
 - smax1Layer: defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the ModelStructure.json based on the TWS model for the Northern Hemisphere
 - smax2fPFT: defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is defined as PFT specific parameters from forcing
 - smax2fRD4: defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing
 - smax2Layer: defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the ModelStructure.json based on the older version of the Pre-Tokyo Model
 - uniform: distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties
"""
soilWBase