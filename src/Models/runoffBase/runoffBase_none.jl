export runoffBase_none

struct runoffBase_none <: runoffBase end

function define(params::runoffBase_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    base_runoff = z_zero

    ## pack land variables
    @pack_nt base_runoff ⇒ land.fluxes
    return land
end

@doc """
sets the base runoff to zero

# Instantiate:
Instantiate time-invariant variables for runoffBase_none


---

# Extended help
"""
runoffBase_none
