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

purpose(::Type{runoffBase_none}) = "sets the base runoff to zero"

@doc """

$(getModelDocString(runoffBase_none))

---

# Extended help
"""
runoffBase_none
