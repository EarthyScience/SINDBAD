export PET_forcing

struct PET_forcing <: PET end

function compute(p_struct::PET_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_PET ∈ forcing

    PET = f_PET
    ## pack land variables
    @pack_land PET => land.fluxes
    return land
end

@doc """
sets the value of land.fluxes.PET from the forcing

---

# compute:
Set potential evapotranspiration using PET_forcing

*Inputs*
 - forcing.PET read from the forcing data set

*Outputs*
 - land.fluxes.PET: the value of PET for current time step

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
PET_forcing
