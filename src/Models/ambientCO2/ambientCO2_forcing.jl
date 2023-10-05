export ambientCO2_forcing

struct ambientCO2_forcing <: ambientCO2 end

function define(p_struct::ambientCO2_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_ambient_CO2 ∈ forcing
    ## pack land variables
    @pack_land f_ambient_CO2 => land.states
    return land
end

function compute(p_struct::ambientCO2_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_ambient_CO2 ∈ forcing

    ambient_CO2 = f_ambient_CO2

    ## pack land variables
    @pack_land ambient_CO2 => land.states
    return land
end

@doc """
sets the value of land.states.ambient_CO2 from the forcing in every time step

---

# compute:
Set/get ambient co2 concentration using ambientCO2_forcing

*Inputs*
 - forcing.ambient_CO2 read from the forcing data set

*Outputs*
 - land.states.ambient_CO2: the value of LAI for current time step
 - land.states.ambient_CO2

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
ambientCO2_forcing
