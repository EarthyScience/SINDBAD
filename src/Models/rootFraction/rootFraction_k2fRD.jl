export rootFraction_k2fRD

#! format: off
@bounds @describe @units @with_kw struct rootFraction_k2fRD{T1,T2} <: rootFraction
    k2_scale::T1 = 0.02 | (0.001, 0.2) | "scales vegFrac to define fraction of 2nd soil layer available for transpiration" | ""
    k1_scale::T2 = 0.5 | (0.01, 0.99) | "scales vegFrac to fraction of 1st soil layer available for transpiration" | ""
end
#! format: on

function define(p_struct::rootFraction_k2fRD, forcing, land, helpers)
    @unpack_rootFraction_k2fRD p_struct

    # check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
    if length(land.pools.soilW) != 2
        error("rootFraction_k2Layer: approach works for 2 soil layers only.")
    end
    # create the arrays to fill in the soil properties 
    p_frac_root_to_soil_depth = ones(helpers.numbers.num_type, length(land.pools.soilW))

    ## pack land variables
    @pack_land (p_frac_root_to_soil_depth) => land.rootFraction
    return land
end

function compute(p_struct::rootFraction_k2fRD, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootFraction_k2fRD p_struct

    ## unpack land variables
    @unpack_land (p_frac_root_to_soil_depth) ∈ land.rootFraction

    ## unpack land variables
    @unpack_land frac_vegetation ∈ land.states

    ## calculate variables
    # check if the number of soil layers & number of elements in soil
    k1RootFrac = frac_vegetation * k1_scale # the fraction of water that a root can uptake from the 1st soil layer
    k2RootFrac = frac_vegetation * k2_scale # the fraction of water that a root can uptake from the 1st soil layer
    # set the properties
    # 1st Layer
    p_frac_root_to_soil_depth[1] = p_frac_root_to_soil_depth[1] * k1RootFrac
    # 2nd Layer
    p_frac_root_to_soil_depth[2] = p_frac_root_to_soil_depth[2] * k2RootFrac

    ## pack land variables
    @pack_land p_frac_root_to_soil_depth => land.rootFraction
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; & for the second soil layer additional as function of RD

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_k2fRD

*Inputs*
 - helpers.pools.: soil layers & depths
 - k2_RDscale : RD scalar for k2
 - land.states.frac_vegetation : vegetation fraction

*Outputs*
 - land.rootFraction.p_frac_root_to_soil_depth as nPix;nZix for soilW

# instantiate:
instantiate/instantiate time-invariant variables for rootFraction_k2fRD


---

# Extended help

*References*

*Versions*
 - 1.0 on 10.02.2020  

*Created by:*
 - ttraut
"""
rootFraction_k2fRD
