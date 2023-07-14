export rootFraction_constant

#! format: off
@bounds @describe @units @with_kw struct rootFraction_constant{T1} <: rootFraction
    constant_frac_root_to_soil_depth::T1 = 0.05 | (0.01, 0.15) | "root fraction" | ""
end
#! format: on

function define(p_struct::rootFraction_constant, forcing, land, helpers)
    @unpack_rootFraction_constant p_struct
    @unpack_land soil_layer_thickness ∈ land.soilWBase
    @unpack_land soilW ∈ land.pools
    cumulative_soil_depths = cumsum(soil_layer_thickness)
    ## instantiate
    p_frac_root_to_soil_depth = zero(land.pools.soilW) .+ helpers.numbers.𝟙

    ## pack land variables
    @pack_land begin
        p_frac_root_to_soil_depth => land.rootFraction
        cumulative_soil_depths => land.rootFraction
    end

    return land
end

function compute(p_struct::rootFraction_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootFraction_constant p_struct

    ## unpack land variables
    @unpack_land begin
        soil_layer_thickness ∈ land.soilWBase
        (p_frac_root_to_soil_depth, cumulative_soil_depths) ∈ land.rootFraction
        max_root_depth ∈ land.states
        𝟘 ∈ helpers.numbers
    end

    ## calculate variables
    # cumSum!(soil_layer_thickness, cumulative_soil_depths)
    # max_root_depth = min(max_root_depth, sum(soilDepths)); # maximum rootingdepth
    for sl ∈ eachindex(land.pools.soilW)
        soilcumuD = cumulative_soil_depths[sl]
        rootOver = max_root_depth - soilcumuD
        rootFrac = rootOver > 𝟘 ? constant_frac_root_to_soil_depth : zero(constant_frac_root_to_soil_depth)
        @rep_elem rootFrac => (p_frac_root_to_soil_depth, sl, :soilW)
    end

    ## pack land variables
    @pack_land p_frac_root_to_soil_depth => land.rootFraction
    return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_constant

*Inputs*
 - land.states.maxRootD

*Outputs*
 - land.rootFraction.p_frac_root_to_soil_depth

# instantiate:
instantiate/instantiate time-invariant variables for rootFraction_constant


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
rootFraction_constant
