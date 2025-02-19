export runoffOverland_none

struct runoffOverland_none <: runoffOverland end

function define(params::runoffOverland_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    overland_runoff = z_zero

    ## pack land variables
    @pack_nt overland_runoff ⇒ land.fluxes
    return land
end

@doc """
sets overland runoff to zero

# Instantiate:
Instantiate time-invariant variables for runoffOverland_none


---

# Extended help
"""
runoffOverland_none
