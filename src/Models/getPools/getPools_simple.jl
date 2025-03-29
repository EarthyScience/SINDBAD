export getPools_simple

struct getPools_simple <: getPools end

function define(params::getPools_simple, forcing, land, helpers)
    ## unpack land variables
    @unpack_nt begin
        z_zero ⇐ land.constants
    end
    ## calculate variables
    WBP = z_zero
    @pack_nt WBP ⇒ land.states
    return land
end


function compute(params::getPools_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        rain ⇐ land.fluxes
        WBP ⇐ land.states
    end
    ## calculate variables
    WBP = oftype(WBP, rain)

    @pack_nt WBP ⇒ land.states
    return land
end

purpose(::Type{getPools_simple}) = "gets the amount of water available for the current time step"

@doc """

$(getBaseDocString(getPools_simple))

---

# Extended help

*References*

*Versions*
 - 1.0 on 19.11.2019 [skoirala]: added the documentation & cleaned the code, added json with development stage

*Created by:*
 - mjung
 - ncarvalhais
 - skoirala
"""
getPools_simple
