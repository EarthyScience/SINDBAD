export NDWI_forcing

struct NDWI_forcing <: NDWI end

function compute(params::NDWI_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_NDWI ∈ forcing

    NDWI = f_NDWI
    ## pack land variables
    @pack_land NDWI → land.states
    return land
end

@doc """
sets the value of land.states.NDWI from the forcing in every time step

---

# compute:
Normalized difference water index using NDWI_forcing

*Inputs*
 - forcing.NDWI read from the forcing data set

*Outputs*
 - land.states.NDWI: the value of NDWI for current time step
 - land.states.NDWI

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]

*Created by:*
 - sbesnard
"""
NDWI_forcing
