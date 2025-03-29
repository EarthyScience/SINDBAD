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

purpose(::Type{saturatedFraction_none}) = "sets the land.states.soilWSatFrac [saturated soil fraction] to zero"

@doc """

$(getBaseDocString())

---

# Extended help
"""
saturatedFraction_none
