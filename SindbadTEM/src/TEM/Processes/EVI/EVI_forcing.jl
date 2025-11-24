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

purpose(::Type{EVI_forcing}) = "Gets EVI from forcing data."

@doc """

$(getProcessDocstring(EVI_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
EVI_forcing
