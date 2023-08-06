export runoffSurface_directIndirect

#! format: off
@bounds @describe @units @with_kw struct runoffSurface_directIndirect{T1,T2} <: runoffSurface
    dc::T1 = 0.01 | (0.0001, 1.0) | "delayed surface runoff coefficient" | ""
    rf::T2 = 0.5 | (0.0001, 1.0) | "fraction of overland runoff that recharges the surface water storage" | ""
end
#! format: on

function compute(p_struct::runoffSurface_directIndirect, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSurface_directIndirect p_struct

    ## unpack land variables
    @unpack_land begin
        surfaceW ∈ land.pools
        ΔsurfaceW ∈ land.states
        overland_runoff ∈ land.fluxes
        (z_zero, o_one) ∈ land.wCycleBase
        n_surfaceW ∈ land.wCycleBase
    end
    # fraction of overland runoff that recharges the surface water & the
    #fraction that flows out directly
    runoffSurfaceDirect = (o_one - rf) * overland_runoff

    # fraction of surface storage that flows out irrespective of input
    suw_recharge = rf * overland_runoff
    runoffSurfaceIndirect = dc * sum(surfaceW + ΔsurfaceW)

    # get the total surface runoff
    surface_runoff = runoffSurfaceDirect + runoffSurfaceIndirect

    # update the delta storage
    ΔsurfaceW[1] = ΔsurfaceW[1] + suw_recharge # assumes all the recharge supplies the first surface water layer
    ΔsurfaceW .= ΔsurfaceW .- runoffSurfaceIndirect / n_surfaceW # assumes all layers contribute equally to indirect component of surface runoff

    ## pack land variables
    @pack_land begin
        (surface_runoff, runoffSurfaceDirect, runoffSurfaceIndirect, suw_recharge) => land.fluxes
        ΔsurfaceW => land.states
    end
    return land
end

function update(p_struct::runoffSurface_directIndirect, forcing, land, helpers)
    @unpack_runoffSurface_directIndirect p_struct

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
assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage

# Parameters
$(SindbadParameters)

---

# compute:
Runoff from surface water storages using runoffSurface_directIndirect

*Inputs*
 - land.fluxes.overland_runoff

*Outputs*

# update

update pools and states in runoffSurface_directIndirect


---

# Extended help

*References*

*Versions*

*Created by:*
 - skoirala
"""
runoffSurface_directIndirect
