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

@doc """
sets interflow runoff to zero

# Instantiate:
Instantiate time-invariant variables for runoffInterflow_none


---

# Extended help
"""
runoffInterflow_none
