export treeFraction_forcing

struct treeFraction_forcing <: treeFraction end

function compute(params::treeFraction_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt frac_tree ⇐ forcing

    ## pack land variables
    @pack_nt frac_tree ⇒ land.states
    return land
end

purpose(::Type{treeFraction_forcing}) = "sets the value of land.states.frac_tree from the forcing in every time step"

@doc """

$(getBaseDocString(treeFraction_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
treeFraction_forcing
