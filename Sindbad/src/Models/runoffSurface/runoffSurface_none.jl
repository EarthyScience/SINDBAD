export runoffSurface_none

struct runoffSurface_none <: runoffSurface end

function define(params::runoffSurface_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    surface_runoff = z_zero

    ## pack land variables
    @pack_nt surface_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffSurface_none}) = "Sets surface runoff to 0."

@doc """

$(getModelDocString(runoffSurface_none))

---

# Extended help
"""
runoffSurface_none
