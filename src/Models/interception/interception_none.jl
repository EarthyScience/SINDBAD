export interception_none

struct interception_none <: interception end

function define(params::interception_none, forcing, land, helpers)

    ## calculate variables
    interception = land.constants.z_zero

    ## pack land variables
    @pack_land interception → land.fluxes
    return land
end

@doc """
sets the interception evaporation to zero

# instantiate:
instantiate/instantiate time-invariant variables for interception_none


---

# Extended help
"""
interception_none
