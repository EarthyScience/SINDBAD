export ambientCO2_forcing

struct ambientCO2_forcing <: ambientCO2 end


function compute(params::ambientCO2_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_ambient_CO2 ∈ forcing

    ambient_CO2 = f_ambient_CO2

    ## pack land variables
    @pack_land ambient_CO2 → land.states
    return land
end

@doc """
sets the value of ambient_CO2 from the forcing in every time step

---

# compute:
Set/get ambient co2 concentration using ambientCO2_forcing

*Inputs*
 - forcing.f_ambient_CO2 read from the forcing data set

*Outputs*
 - land.states.ambient_CO2: the value of ambient_CO2 for current time step

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
ambientCO2_forcing
