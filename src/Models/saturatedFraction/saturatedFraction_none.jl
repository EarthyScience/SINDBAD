export saturatedFraction_none

struct saturatedFraction_none <: saturatedFraction end

function define(params::saturatedFraction_none, forcing, land, helpers)

    ## calculate variables
    satFrac = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land satFrac => land.states
    return land
end

@doc """
sets the land.states.soilWSatFrac [saturated soil fraction] toz_zero (pix, 1)

# instantiate:
instantiate/instantiate time-invariant variables for saturatedFraction_none


---

# Extended help
"""
saturatedFraction_none
