export NDWI_constant

#! format: off
@bounds @describe @units @with_kw struct NDWI_constant{T1} <: NDWI
    constant_NDWI::T1 = 1.0 | (0.0, 1.0) | "NDWI" | ""
end
#! format: on

function compute(params::NDWI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_NDWI_constant params

    ## calculate variables
    NDWI = constant_NDWI

    ## pack land variables
    @pack_land NDWI → land.states
    return land
end

@doc """
sets the value of NDWI as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Normalized difference water index using NDWI_constant

*Inputs*

*Outputs*
 - land.states.NDWI: an extra forcing that creates a time series of constant NDWI
 - land.states.NDWI

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
NDWI_constant
