export rootFraction_k2Layer

#! format: off
@bounds @describe @units @with_kw struct rootFraction_k2Layer{T1,T2} <: rootFraction
    k2::T1 = 0.02 | (0.001, 0.2) | "fraction of 2nd soil layer available for transpiration" | ""
    k1::T2 = 0.5 | (0.01, 0.99) | "fraction of 1st soil layer available for transpiration" | ""
end
#! format: on

function define(o::rootFraction_k2Layer, forcing, land, helpers)
    @unpack_rootFraction_k2Layer o

    ## precomputations/check

    # check if the number of soil layers is equal to 2 
    if length(land.pools.soilW) != 2
        error("rootFraction_k2Layer approach works for 2 soil layers only.")
    end
    # create the arrays to fill in the soil properties 
    p_fracRoot2SoilD = ones(helpers.numbers.num_type, length(land.pools.soilW))

    ## pack land variables
    @pack_land (p_fracRoot2SoilD) => land.rootFraction
    return land
end

function compute(o::rootFraction_k2Layer, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootFraction_k2Layer o

    ## unpack land variables
    @unpack_land (p_fracRoot2SoilD) ∈ land.rootFraction

    ## calculate variables
    k1RootFrac = k1 # the fraction of water that a root can uptake from the 1st soil layer
    k2RootFrac = k2 # the fraction of water that a root can uptake from the 1st soil layer
    # set the properties
    # 1st Layer
    p_fracRoot2SoilD[1] = p_fracRoot2SoilD[1] * k1RootFrac
    # 2nd Layer
    p_fracRoot2SoilD[2] = p_fracRoot2SoilD[2] * k2RootFrac

    ## pack land variables
    @pack_land p_fracRoot2SoilD => land.rootFraction
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_k2Layer

*Inputs*
 - helpers.pools.: soil layers & depths

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW

# instantiate:
instantiate/instantiate time-invariant variables for rootFraction_k2Layer


---

# Extended help

*References*

*Versions*
 - 1.0 on 09.01.2020  

*Created by:*
 - ttraut
"""
rootFraction_k2Layer
