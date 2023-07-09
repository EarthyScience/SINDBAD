export EVI_constant

#! format: off
@bounds @describe @units @with_kw struct EVI_constant{T1} <: EVI
    constantEVI::T1 = 1.0 | (0.0, 1.0) | "EVI" | ""
end
#! format: on

function compute(p_struct::EVI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_EVI_constant p_struct

    ## calculate variables
    EVI = constantEVI

    ## pack land variables
    @pack_land EVI => land.states
    return land
end

@doc """
sets the value of EVI as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Enhanced vegetation index using EVI_constant

*Inputs*

*Outputs*
 - land.states.EVI: an extra forcing that creates a time series of constant EVI
 - land.states.EVI

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
EVI_constant
