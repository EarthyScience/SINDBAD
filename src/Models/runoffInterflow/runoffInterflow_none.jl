export runoffInterflow_none

struct runoffInterflow_none <: runoffInterflow end

function define(p_struct::runoffInterflow_none, forcing, land, helpers)

    ## calculate variables
    interflow_runoff = helpers.numbers.𝟘

    ## pack land variables
    @pack_land interflow_runoff => land.fluxes
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
