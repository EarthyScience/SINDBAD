export interception_none

struct interception_none <: interception end

function define(params::interception_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    interception = z_zero

    ## pack land variables
    @pack_nt interception ⇒ land.fluxes
    return land
end

purpose(::Type{interception_none}) = "sets the interception evaporation to zero"

@doc """

$(getBaseDocString(interception_none))

---

# Extended help
"""
interception_none
