export saturatedFraction_none

struct saturatedFraction_none <: saturatedFraction end

function define(params::saturatedFraction_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    satFrac = z_zero

    ## pack land variables
    @pack_nt satFrac ⇒ land.states
    return land
end

@doc """
sets the land.states.soilWSatFrac [saturated soil fraction] toz_zero (pix, 1)

# Instantiate:
Instantiate time-invariant variables for saturatedFraction_none


---

# Extended help
"""
saturatedFraction_none
