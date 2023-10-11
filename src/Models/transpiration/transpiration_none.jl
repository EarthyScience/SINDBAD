export transpiration_none

struct transpiration_none <: transpiration end

function define(params::transpiration_none, forcing, land, helpers)

    ## calculate variables
    transpiration = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land transpiration => land.fluxes
    return land
end

@doc """
sets the actual transpiration to zero

# instantiate:
instantiate/instantiate time-invariant variables for transpiration_none


---

# Extended help
"""
transpiration_none
