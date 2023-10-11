export EVI_forcing

struct EVI_forcing <: EVI end

function compute(params::EVI_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_EVI ∈ forcing

    EVI = f_EVI
    ## pack land variables
    @pack_land EVI => land.states
    return land
end

@doc """
sets the value of land.states.EVI from the forcing in every time step

---

# compute:
Enhanced vegetation index using EVI_forcing

*Inputs*
 - forcing.EVI read from the forcing data set

*Outputs*
 - land.states.EVI: the value of EVI for current time step
 - land.states.EVI

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
EVI_forcing
