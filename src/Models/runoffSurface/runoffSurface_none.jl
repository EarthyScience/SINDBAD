export runoffSurface_none

struct runoffSurface_none <: runoffSurface end

function define(params::runoffSurface_none, forcing, land, helpers)
    @unpack_land z_zero ∈ land.constants

    ## calculate variables
    surface_runoff = z_zero

    ## pack land variables
    @pack_land surface_runoff → land.fluxes
    return land
end

@doc """
sets surface runoff [surface_runoff] from the storage to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffSurface_none


---

# Extended help
"""
runoffSurface_none
