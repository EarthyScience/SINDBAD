export autoRespiration_none

struct autoRespiration_none <: autoRespiration end

function define(params::autoRespiration_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_efflux = zero(cEco)

    ## pack land variables
    @pack_nt c_eco_efflux ⇒ land.states
    return land
end

@doc """
sets the co2 efflux from all vegetation pools to zero

# instantiate:
instantiate/instantiate time-invariant variables for autoRespiration_none


---

# Extended help
"""
autoRespiration_none
