export aRespiration_none

struct aRespiration_none <: aRespiration end

function define(o::aRespiration_none, forcing, land, helpers)
    @unpack_land cEcoEfflux ∈ land.states

    ## calculate variables
    zix = getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
    @rep_elem 𝟘 => (cEcoEfflux, zix, :cEco)

    ## pack land variables
    @pack_land cEcoEfflux => land.states
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
