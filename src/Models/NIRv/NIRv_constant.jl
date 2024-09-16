export NIRv_constant

#! format: off
@bounds @describe @units @with_kw struct NIRv_constant{T1} <: NIRv
    constant_NIRv::T1 = 1.0 | (0.0, 1.0) | "NIRv" | ""
end
#! format: on

function precompute(params::NIRv_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_NIRv_constant params

    ## calculate variables
    NIRv = constant_NIRv

    ## pack land variables
    @pack_nt NIRv ⇒ land.states
    return land
end

@doc """
sets the value of NIRv as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Near-infrared reflectance of terrestrial vegetation using NIRv_constant

*Inputs*

*Outputs*
 - land.states.NIRv: an extra forcing that creates a time series of constant NIRv
 - land.states.NIRv

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
NIRv_constant
