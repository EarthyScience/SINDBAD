export sublimation_none

struct sublimation_none <: sublimation end

function define(params::sublimation_none, forcing, land, helpers)
    @unpack_nt snowW ⇐ land.pools
    ## calculate variables
    sublimation = zero(eltype(snowW))

    ## pack land variables
    @pack_nt sublimation ⇒ land.fluxes
    return land
end

purpose(::Type{sublimation_none}) = "sets the snow sublimation to zero"

@doc """

$(getModelDocString(sublimation_none))

---

# Extended help
"""
sublimation_none
