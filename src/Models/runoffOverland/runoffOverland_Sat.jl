export runoffOverland_Sat

struct runoffOverland_Sat <: runoffOverland end

function compute(params::runoffOverland_Sat, forcing, land, helpers)

    ## unpack land variables
    @unpack_land sat_excess_runoff ∈ land.fluxes

    ## calculate variables
    overland_runoff = sat_excess_runoff

    ## pack land variables
    @pack_land overland_runoff => land.fluxes
    return land
end

@doc """
assumes overland flow to be saturation excess runoff

---

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_Sat

*Inputs*
 - land.fluxes.sat_excess_runoff: saturation excess runoff

*Outputs*
 - land.fluxes.overland_runoff : runoff over land [mm/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
runoffOverland_Sat
