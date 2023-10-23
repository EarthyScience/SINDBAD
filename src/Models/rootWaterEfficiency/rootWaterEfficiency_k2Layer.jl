export rootWaterEfficiency_k2Layer

#! format: off
@bounds @describe @units @with_kw struct rootWaterEfficiency_k2Layer{T1,T2} <: rootWaterEfficiency
    k2::T1 = 0.02 | (0.001, 0.2) | "fraction of 2nd soil layer available for transpiration" | ""
    k1::T2 = 0.5 | (0.01, 0.99) | "fraction of 1st soil layer available for transpiration" | ""
end
#! format: on

function define(params::rootWaterEfficiency_k2Layer, forcing, land, helpers)
    @unpack_rootWaterEfficiency_k2Layer params
    @unpack_nt soilW ⇐ land.pools

    ## precomputations/check

    # check if the number of soil layers is equal to 2
    if length(soilW) != 2
        error("rootWaterEfficiency_k2Layer approach works for 2 soil layers only.")
    end
    # create the arrays to fill in the soil properties
    root_water_efficiency = one.(soilW)

    ## pack land variables
    @pack_nt root_water_efficiency ⇒ land.diagnostics
    return land
end

function compute(params::rootWaterEfficiency_k2Layer, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootWaterEfficiency_k2Layer params

    ## unpack land variables
    @unpack_nt root_water_efficiency ⇐ land.diagnostics

    ## calculate variables
    k1_root_water_efficiency = k1 # the fraction of water that a root can uptake from the 1st soil layer
    k2_root_water_efficiency = k2 # the fraction of water that a root can uptake from the 1st soil layer
    # set the properties
    # 1st Layer
    @rep_elem k1_root_water_efficiency ⇒ (root_water_efficiency, 1, :soilW)
    # 2nd Layer
    @rep_elem k2_root_water_efficiency ⇒ (root_water_efficiency, 2, :soilW)


    ## pack land variables
    @pack_nt root_water_efficiency ⇒ land.diagnostics
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootWaterEfficiency_k2Layer

*Inputs*
 - helpers.pools.: soil layers & depths

*Outputs*
 - land.states.root_water_efficiency as nZix for soilW

# instantiate:
instantiate/instantiate time-invariant variables for rootWaterEfficiency_k2Layer


---

# Extended help

*References*

*Versions*
 - 1.0 on 09.01.2020  

*Created by:*
 - ttraut
"""
rootWaterEfficiency_k2Layer
