export LAI_constant

#! format: off
@bounds @describe @units @with_kw struct LAI_constant{T1} <: LAI
    constant_LAI::T1 = 3.0 | (1.0, 12.0) | "LAI" | "m2/m2"
end
#! format: on

function precompute(params::LAI_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_LAI_constant params

    ## calculate variables
    LAI = constant_LAI

    ## pack land variables
    @pack_land LAI → land.states
    return land
end

@doc """
sets the value of LAI as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Leaf area index using LAI_constant

*Inputs*

*Outputs*
 - land.states.LAI: an extra forcing that creates a time series of constant LAI

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
LAI_constant
