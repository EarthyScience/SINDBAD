export runoffInterflow_none

struct runoffInterflow_none <: runoffInterflow end

function define(params::runoffInterflow_none, forcing, land, helpers)
    @unpack_land z_zero ∈ land.constants

    ## calculate variables
    interflow_runoff = z_zero

    ## pack land variables
    @pack_land interflow_runoff → land.fluxes
    return land
end

@doc """
sets interflow runoff to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffInterflow_none


---

# Extended help
"""
runoffInterflow_none
