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

purpose(::Type{runoffOverland_none}) = "Sets overland runoff to 0."

@doc """

$(getModelDocString(runoffOverland_none))

---

# Extended help
"""
runoffOverland_none
