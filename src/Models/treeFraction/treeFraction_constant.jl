export treeFraction_constant

#! format: off
@bounds @describe @units @with_kw struct treeFraction_constant{T1} <: treeFraction
    constant_frac_tree::T1 = 1.0 | (0.3, 1.0) | "Tree fraction" | ""
end
#! format: on


function precompute(params::treeFraction_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_treeFraction_constant params

    ## calculate variables
    frac_tree = constant_frac_tree

    ## pack land variables
    @pack_land frac_tree → land.states
    return land
end

@doc """
sets the value of frac_tree as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Fractional coverage of trees using treeFraction_constant

*Inputs*
 - info helper for array

*Outputs*
 - land.states.frac_tree: an extra forcing that creates a time series of constant frac_tree

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
treeFraction_constant
