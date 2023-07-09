export aRespiration_none

struct aRespiration_none <: aRespiration end

function define(p_struct::aRespiration_none, forcing, land, helpers)
    @unpack_land c_efflux ∈ land.states

    ## calculate variables
    zix = getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
    @rep_elem 𝟘 => (c_efflux, zix, :cEco)

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
