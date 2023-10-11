export runoffOverland_Inf

struct runoffOverland_Inf <: runoffOverland end

function compute(params::runoffOverland_Inf, forcing, land, helpers)

    ## unpack land variables
    @unpack_land inf_excess_runoff ∈ land.fluxes

    ## calculate variables
    overland_runoff = inf_excess_runoff

    ## pack land variables
    @pack_land overland_runoff => land.fluxes
    return land
end

@doc """
assumes overland flow to be infiltration excess runoff
---

# compute:

*Inputs*
 - land.fluxes.inf_excess_runoff: infiltration excess runoff

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
runoffOverland_Inf
