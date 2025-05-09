export ambientCO2_forcing

struct ambientCO2_forcing <: ambientCO2 end


function compute(params::ambientCO2_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_ambient_CO2 ⇐ forcing

    ambient_CO2 = f_ambient_CO2

    ## pack land variables
    @pack_nt ambient_CO2 ⇒ land.states
    return land
end

purpose(::Type{ambientCO2_forcing}) = "sets the value of ambient_CO2 from the forcing in every time step"

@doc """

$(getModelDocString(ambientCO2_forcing))

---

# Extended help
This function assigns the value of ambient CO2 concentration from the forcing data (`f_ambient_CO2`) to the land model state for the current time step.

*References*
 - None

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
ambientCO2_forcing
