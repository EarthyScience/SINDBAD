export ambientCO2_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct ambientCO2_constant{T1} <: ambientCO2
    constant_ambient_CO2::T1 = 400.0 | (200.0, 5000.0) | "atmospheric CO2 concentration" | "ppm" | ""
end
#! format: on

function precompute(params::ambientCO2_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_ambientCO2_constant params

    ## calculate variables
    ambient_CO2 = constant_ambient_CO2

    ## pack land variables
    @pack_nt ambient_CO2 ⇒ land.states
    return land
end

purpose(::Type{ambientCO2_constant}) = "sets the value of ambient_CO2 as a constant"
@doc """
    $(getBaseDocString(ambientCO2_constant))

---

# Extended help
This function assigns a constant value of ambient CO2 concentration to the land model state. 
The value is derived from the `constant_ambient_CO2` parameter defined in the `ambientCO2_constant` structure.

*References*
 - None

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
ambientCO2_constant
