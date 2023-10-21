export autoRespiration_none

struct autoRespiration_none <: autoRespiration end

function define(params::autoRespiration_none, forcing, land, helpers)

    ## calculate variables
    c_eco_efflux = zero(land.pools.cEco)

    ## pack land variables
    @pack_land c_eco_efflux → land.states
    return fluxes
end

@doc """
sets the co2 efflux from all vegetation pools to zero

# instantiate:
instantiate/instantiate time-invariant variables for autoRespiration_none


---

# Extended help
"""
autoRespiration_none
