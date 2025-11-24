export evaporation_none

struct evaporation_none <: evaporation end

function define(params::evaporation_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    evaporation = z_zero

    ## pack land variables
    @pack_nt evaporation ⇒ land.fluxes
    return land
end

purpose(::Type{evaporation_none}) = "Bare soil evaporation set to 0."

@doc """

$(getProcessDocstring(evaporation_none))

---

# Extended help
"""
evaporation_none
