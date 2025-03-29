export snowFraction_none

struct snowFraction_none <: snowFraction end

function define(params::snowFraction_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    frac_snow = z_zero

    ## pack land variables
    @pack_nt frac_snow ⇒ land.states
    return land
end

purpose(::Type{snowFraction_none}) = "sets the snow fraction to zero"

@doc """

$(getBaseDocString())

---

# Extended help
"""
snowFraction_none
