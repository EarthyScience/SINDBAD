export NDVI_forcing

struct NDVI_forcing <: NDVI end

function compute(params::NDVI_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_NDVI ⇐ forcing

    NDVI = f_NDVI

    ## pack land variables
    @pack_nt NDVI ⇒ land.states
    return land
end

purpose(::Type{NDVI_forcing}) = "sets the value of land.states.NDVI from the forcing in every time step"

@doc """

$(getBaseDocString(NDVI_forcing))

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]

*Created by:*
 - sbesnard
"""
NDVI_forcing
