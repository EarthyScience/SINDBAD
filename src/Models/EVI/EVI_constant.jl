export EVI_constant

#! format: off
@bounds @describe @units @with_kw struct EVI_constant{T1} <: EVI
    constant_EVI::T1 = 1.0 | (0.0, 1.0) | "EVI" | ""
end
#! format: on

function compute(params::EVI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_EVI_constant params

    ## calculate variables
    EVI = constant_EVI

    ## pack land variables
    @pack_land EVI → land.states
    return land
end

@doc """
sets the value of EVI as a constant

# Parameters
$(SindbadParameters)

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
