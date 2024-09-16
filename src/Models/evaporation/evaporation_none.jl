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

@doc """
sets the soil evaporation to zero

# instantiate:
instantiate/instantiate time-invariant variables for evaporation_none
    

---

# Extended help
"""
evaporation_none
