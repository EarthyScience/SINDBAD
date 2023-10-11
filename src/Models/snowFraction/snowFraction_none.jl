export snowFraction_none

struct snowFraction_none <: snowFraction end

function define(params::snowFraction_none, forcing, land, helpers)

    ## calculate variables
    frac_snow = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land frac_snow => land.states
    return land
end

@doc """
sets the snow fraction to zero

# instantiate:
instantiate/instantiate time-invariant variables for snowFraction_none


---

# Extended help
"""
snowFraction_none
