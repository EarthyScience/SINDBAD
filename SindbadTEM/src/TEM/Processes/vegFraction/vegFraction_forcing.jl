export vegFraction_forcing

struct vegFraction_forcing <: vegFraction end

function compute(params::vegFraction_forcing, forcing, land, helpers)
    @unpack_nt f_frac_vegetation ⇐ forcing

    frac_vegetation = first(f_frac_vegetation)

    ## pack land variables
    @pack_nt frac_vegetation ⇒ land.states
    return land
end

purpose(::Type{vegFraction_forcing}) = "Gets vegetation fraction from forcing data."

@doc """

$(getProcessDocstring(vegFraction_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
vegFraction_forcing
