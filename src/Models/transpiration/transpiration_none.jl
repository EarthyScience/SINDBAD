export transpiration_none

struct transpiration_none <: transpiration end

function define(params::transpiration_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants
    ## calculate variables
    transpiration = z_zero

    ## pack land variables
    @pack_nt transpiration ⇒ land.fluxes
    return land
end

purpose(::Type{transpiration_none}) = "sets the actual transpiration to zero"

@doc """

$(getBaseDocString())

---

# Extended help
"""
transpiration_none
