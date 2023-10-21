export sublimation_none

struct sublimation_none <: sublimation end

function define(params::sublimation_none, forcing, land, helpers)

    ## calculate variables
    sublimation = zero(eltype(land.pools.snowW))

    ## pack land variables
    @pack_land sublimation → land.fluxes
    return land
end

@doc """
sets the snow sublimation to zero

# instantiate:
instantiate/instantiate time-invariant variables for sublimation_none


---

# Extended help
"""
sublimation_none
