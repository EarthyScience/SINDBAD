export saturatedFraction_none

struct saturatedFraction_none <: saturatedFraction end

function define(o::saturatedFraction_none, forcing, land, helpers)

    ## calculate variables
    satFrac = helpers.numbers.𝟘

    ## pack land variables
    @pack_land satFrac => land.states
    return land
end

@doc """
sets the land.states.soilWSatFrac [saturated soil fraction] to 𝟘  (pix, 1)

# instantiate:
instantiate/instantiate time-invariant variables for saturatedFraction_none


---

# Extended help
"""
saturatedFraction_none
