export aRespiration_none

struct aRespiration_none <: aRespiration end

function define(p_struct::aRespiration_none, forcing, land, helpers)

    ## calculate variables
    c_efflux = zero(land.pools.cEco)

    ## pack land variables
    @pack_land c_efflux => land.states
    return land
end

@doc """
sets the outflow from all vegetation pools to zero

# instantiate:
instantiate/instantiate time-invariant variables for aRespiration_none


---

# Extended help
"""
aRespiration_none
