export fAPAR_EVI

#! format: off
@bounds @describe @units @with_kw struct fAPAR_EVI{T1} <: fAPAR
    EVI_to_fAPAR_c::T1 = 0.0 | (-0.2, 0.3) | "intercept of the linear function" | ""
    EVI_to_fAPAR_m::T1 = 1.0 | (0.5, 5) | "slope of the linear function" | ""
end
#! format: on

function compute(p_struct::fAPAR_EVI, forcing, land, helpers)
    @unpack_fAPAR_EVI p_struct

    ## unpack land variables
    @unpack_land EVI ∈ land.states

    ## calculate variables
    fAPAR = EVI_to_fAPAR_m * EVI + EVI_to_fAPAR_c
    fAPAR = clampZeroOne(fAPAR)

    ## pack land variables
    @pack_land fAPAR => land.states
    return land
end

@doc """
calculates the value of fAPAR as a linear function of EVI

# Parameters
$(SindbadParameters)

---

# compute:
Fraction of absorbed photosynthetically active radiation from EVI

*Inputs*
 - land.states.EVI: vegetated fraction, which needs EVI module to be activated

*Outputs*
 - land.states.fAPAR: fAPAR as a fraction of vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
fAPAR_EVI
