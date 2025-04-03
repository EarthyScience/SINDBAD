export NDWI_forcing

struct NDWI_forcing <: NDWI end

function compute(params::NDWI_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_NDWI ⇐ forcing

    NDWI = f_NDWI
    ## pack land variables
    @pack_nt NDWI ⇒ land.states
    return land
end

purpose(::Type{NDWI_forcing}) = "sets the value of land.states.NDWI from the forcing in every time step"

@doc """

$(getBaseDocString(NDWI_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]

*Created by*
 - sbesnard
"""
NDWI_forcing
