export rootWaterEfficiency_k2fRD

#! format: off
@bounds @describe @units @with_kw struct rootWaterEfficiency_k2fRD{T1,T2} <: rootWaterEfficiency
    k2_scale::T1 = 0.02 | (0.001, 0.2) | "scales vegFrac to define fraction of 2nd soil layer available for transpiration" | ""
    k1_scale::T2 = 0.5 | (0.01, 0.99) | "scales vegFrac to fraction of 1st soil layer available for transpiration" | ""
end
#! format: on

function define(params::rootWaterEfficiency_k2fRD, forcing, land, helpers)
    @unpack_rootWaterEfficiency_k2fRD params

    # check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
    if length(land.pools.soilW) != 2
        error("rootWaterEfficiency_k2Layer: approach works for 2 soil layers only.")
    end
    # create the arrays to fill in the soil properties 
    root_water_efficiency = one.(land.pools.soilW)

    ## pack land variables
    @pack_land root_water_efficiency => land.states
    return land
end

function compute(params::rootWaterEfficiency_k2fRD, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootWaterEfficiency_k2fRD params

    ## unpack land variables
    @unpack_land root_water_efficiency ∈ land.states

    ## unpack land variables
    @unpack_land frac_vegetation ∈ land.states

    ## calculate variables
    k1_root_water_efficiency = frac_vegetation * k1_scale # the fraction of water that a root can uptake from the 1st soil layer
    k2_root_water_efficiency = frac_vegetation * k2_scale # the fraction of water that a root can uptake from the 1st soil layer
    # set the properties
    # 1st Layer
    @rep_elem k1_root_water_efficiency => (root_water_efficiency, 1, :soilW)
    # 2nd Layer
    @rep_elem k2_root_water_efficiency => (root_water_efficiency, 2, :soilW)

    ## pack land variables
    @pack_land root_water_efficiency => land.states
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; & for the second soil layer additional as function of RD

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootWaterEfficiency_k2fRD

*Inputs*
 - helpers.pools.: soil layers & depths
 - k2_RDscale : RD scalar for k2
 - land.states.frac_vegetation : vegetation fraction

*Outputs*
 - land.states.root_water_efficiency as nPix;nZix for soilW

# instantiate:
instantiate/instantiate time-invariant variables for rootWaterEfficiency_k2fRD


---

# Extended help

*References*

*Versions*
 - 1.0 on 10.02.2020  

*Created by:*
 - ttraut
"""
rootWaterEfficiency_k2fRD
