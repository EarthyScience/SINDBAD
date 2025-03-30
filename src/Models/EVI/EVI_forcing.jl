export EVI_forcing

struct EVI_forcing <: EVI end

function compute(params::EVI_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_EVI ⇐ forcing

    EVI = f_EVI
    ## pack land variables
    @pack_nt EVI ⇒ land.states
    return land
end

purpose(::Type{EVI_forcing}) = "sets the value of land.states.EVI from the forcing in every time step"

@doc """

$(getBaseDocString(EVI_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by*
 - skoirala
"""
EVI_forcing
