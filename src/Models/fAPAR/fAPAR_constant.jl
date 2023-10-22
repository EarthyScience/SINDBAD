export fAPAR_constant

#! format: off
@bounds @describe @units @with_kw struct fAPAR_constant{T1} <: fAPAR
    constant_fAPAR::T1 = 0.2 | (0.0, 1.0) | "a constant fAPAR" | ""
end
#! format: on

function precompute(params::fAPAR_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_fAPAR_constant params

    ## calculate variables
    fAPAR = constant_fAPAR

    ## pack land variables
    @pack_land fAPAR → land.states
    return land
end

@doc """
sets the value of fAPAR as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_constant

*Inputs*
 - info helper for array

*Outputs*
 - land.states.fAPAR: an extra forcing that creates a time series of constant fAPAR

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
fAPAR_constant
