export ambientCO2_constant

#! format: off
@bounds @describe @units @with_kw struct ambientCO2_constant{T1} <: ambientCO2
    constant_ambient_CO2::T1 = 400.0 | (200.0, 5000.0) | "atmospheric CO2 concentration" | "ppm"
end
#! format: on

function compute(params::ambientCO2_constant, forcing, land, helpers)
    ## unpack parameters
    @unpack_ambientCO2_constant params

    ## calculate variables
    ambient_CO2 = constant_ambient_CO2

    ## pack land variables
    @pack_land ambient_CO2 => land.states
    return land
end

@doc """
sets the value of ambient_CO2 as a constant

# Parameters
$(SindbadParameters)

---

# compute:
Set/get ambient co2 concentration using ambientCO2_constant

*Inputs*

*Outputs*
 - land.states.ambient_CO2: a constant state of ambient CO2

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
ambientCO2_constant
