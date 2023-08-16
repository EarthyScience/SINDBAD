export vegFraction_constant

#! format: off
@bounds @describe @units @with_kw struct vegFraction_constant{T1} <: vegFraction
    constant_frac_vegetation::T1 = 0.5 | (0.3, 0.9) | "Vegetation fraction" | ""
end
#! format: on

function compute(p_struct::vegFraction_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegFraction_constant p_struct

    ## calculate variables
    frac_vegetation = constant_frac_vegetation

    ## pack land variables
    @pack_land frac_vegetation => land.states
    return land
end

@doc """
sets the value of frac_vegetation as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Fractional coverage of vegetation using vegFraction_constant

*Inputs*
 - constant_frac_vegetationtion

*Outputs*
 - land.states.frac_vegetation: an extra forcing with a constant frac_vegetation

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
vegFraction_constant
