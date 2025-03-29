export runoffInterflow_none

struct runoffInterflow_none <: runoffInterflow end

function define(params::runoffInterflow_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    interflow_runoff = z_zero

    ## pack land variables
    @pack_nt interflow_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffInterflow_none}) = "sets interflow runoff to zero"

@doc """

$(getBaseDocString())

---

# Extended help
"""
runoffInterflow_none
