export rootMaximumDepth_fracSoilD

#! format: off
@bounds @describe @units @with_kw struct rootMaximumDepth_fracSoilD{T1} <: rootMaximumDepth
    constant_frac_max_root_depth::T1 = 0.5 | (0.1, 0.8) | "root depth as a fraction of soil depth" | ""
end
#! format: on

function define(p_struct::rootMaximumDepth_fracSoilD, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootMaximumDepth_fracSoilD p_struct
    @unpack_land soil_layer_thickness ∈ land.soilWBase
    ## calculate variables
    sum_soil_depth = sum(soil_layer_thickness)
    ## pack land variables
    @pack_land begin
        sum_soil_depth => land.rootMaximumDepth
    end
    return land
end

function precompute(p_struct::rootMaximumDepth_fracSoilD, forcing, land, helpers)
    ## unpack parameters
    @unpack_rootMaximumDepth_fracSoilD p_struct
    @unpack_land sum_soil_depth ∈ land.rootMaximumDepth
    ## calculate variables
    # get the soil thickness & root distribution information from input
    max_root_depth = sum_soil_depth * constant_frac_max_root_depth
    # disp(["the maxRootD scalar: " constant_frac_max_root_depth])

    ## pack land variables
    @pack_land max_root_depth => land.states
    return land
end

@doc """
sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD

# Parameters
$(SindbadParameters)

---

# compute:
Maximum rooting depth using rootMaximumDepth_fracSoilD

*Inputs*
 - soil_layer_thickness

*Outputs*
 - land.states.max_root_depth: The maximum rooting depth in mm

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
rootMaximumDepth_fracSoilD
