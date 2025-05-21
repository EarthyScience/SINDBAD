export PET_forcing

struct PET_forcing <: PET end

function compute(params::PET_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_PET ⇐ forcing

    PET = f_PET
    ## pack land variables
    @pack_nt PET ⇒ land.fluxes
    return land
end

purpose(::Type{PET_forcing}) = "sets land.fluxes.PET from the forcing"

@doc """

$(getModelDocString(PET_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
PET_forcing
