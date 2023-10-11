export runoffSurface_all

struct runoffSurface_all <: runoffSurface end

function compute(params::runoffSurface_all, forcing, land, helpers)

    ## unpack land variables
    @unpack_land overland_runoff ∈ land.fluxes

    ## calculate variables
    # all overland flow becomes surface runoff
    surface_runoff = overland_runoff

    ## pack land variables
    @pack_land surface_runoff => land.fluxes
    return land
end

@doc """
assumes all overland runoff is lost as surface runoff

---

# compute:
Runoff from surface water storages using runoffSurface_all

*Inputs*
 - land.fluxes.overland_runoff
 - land.states.surfaceW[1]

*Outputs*
 - land.fluxes.surface_runoff
 - land.pools.surfaceW[1]

---

# Extended help

*References*

*Versions*
 - 1.0 on 20.11.2019 [skoirala]: combine surface_runoff_direct, Indir, suw_recharge  

*Created by:*
 - skoirala
"""
runoffSurface_all
