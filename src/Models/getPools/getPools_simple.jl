export getPools_simple

struct getPools_simple <: getPools end

function define(params::getPools_simple, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        z_zero ∈ land.constants
    end
    ## calculate variables
    WBP = z_zero
    @pack_land WBP → land.states
    return land
end


function compute(params::getPools_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        rain ∈ land.fluxes
        WBP ∈ land.states
    end
    ## calculate variables
    WBP = oftype(WBP, rain)

    @pack_land WBP → land.states
    return land
end

@doc """
gets the amount of water available for the current time step

---

# compute:
Get the amount of water at the beginning of timestep using getPools_simple

*Inputs*
 - amount of rainfall

*Outputs*
 - land.states.WBP: the amount of liquid water input to the system

---

# Extended help

*References*

*Versions*
 - 1.0 on 19.11.2019 [skoirala]: added the documentation & cleaned the code, added json with development stage

*Created by:*
 - mjung
 - ncarval
 - skoirala
"""
getPools_simple
