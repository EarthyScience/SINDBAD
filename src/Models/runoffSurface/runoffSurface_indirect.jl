export runoffSurface_indirect

#! format: off
@bounds @describe @units @with_kw struct runoffSurface_indirect{T1} <: runoffSurface
    dc::T1 = 0.01 | (0.0, 1.0) | "delayed surface runoff coefficient" | ""
end
#! format: on

function compute(p_struct::runoffSurface_indirect, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSurface_indirect p_struct

    ## unpack land variables
    @unpack_land begin
        surfaceW ∈ land.pools
        overland_runoff ∈ land.fluxes
        n_surfaceW ∈ land.wCycleBase
    end

    # fraction of overland runoff that recharges the surface water & the fraction that flows out directly
    suw_recharge = overland_runoff

    # fraction of surface storage that flows out as surface runoff
    surface_runoff = dc * sum(surfaceW)

    # update the delta storage
    ΔsurfaceW[1] = ΔsurfaceW[1] + suw_recharge # assumes all the recharge supplies the first surface water layer
    ΔsurfaceW .= ΔsurfaceW .- surface_runoff / n_surfaceW # assumes all layers contribute equally to indirect component of surface runoff

    ## pack land variables
    @pack_land begin
        (surface_runoff, suw_recharge) => land.fluxes
        ΔsurfaceW => land.states
    end
    return land
end

function update(p_struct::runoffSurface_indirect, forcing, land, helpers)
    @unpack_runoffSurface_indirect p_struct

    ## unpack variables
    @unpack_land begin
        surfaceW ∈ land.pools
        ΔsurfaceW ∈ land.states
    end

    ## update storage pools
    surfaceW .= surfaceW .+ ΔsurfaceW

    # reset ΔsurfaceW to zero
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

    ## pack land variables
    @pack_land begin
        surfaceW => land.pools
        ΔsurfaceW => land.states
    end
    return land
end

@doc """
assumes all overland runoff is recharged to surface water first, which then generates surface runoff

# Parameters
$(SindbadParameters)

---

# compute:
Runoff from surface water storages using runoffSurface_indirect

*Inputs*
 - land.fluxes.overland_runoff
 - land.states.surfaceW[1]

*Outputs*
 - land.fluxes.surface_runoff & its indirect/slow component

# update

update pools and states in runoffSurface_indirect

 - land.pools.surfaceW[1]

---

# Extended help

*References*

*Versions*
 - 1.0 on 20.11.2019 [skoirala]: combine surface_runoff_direct, Indir, suw_recharge  

*Created by:*
 - skoirala
"""
runoffSurface_indirect
