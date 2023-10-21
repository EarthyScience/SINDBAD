export runoffSurface_directIndirect

#! format: off
@bounds @describe @units @with_kw struct runoffSurface_directIndirect{T1,T2} <: runoffSurface
    dc::T1 = 0.01 | (0.0001, 1.0) | "delayed surface runoff coefficient" | ""
    rf::T2 = 0.5 | (0.0001, 1.0) | "fraction of overland runoff that recharges the surface water storage" | ""
end
#! format: on

function compute(params::runoffSurface_directIndirect, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSurface_directIndirect params

    ## unpack land variables
    @unpack_land begin
        surfaceW ∈ land.pools
        ΔsurfaceW ∈ land.pools
        overland_runoff ∈ land.fluxes
        (z_zero, o_one) ∈ land.constants
        n_surfaceW ∈ land.diagnostics
    end
    # fraction of overland runoff that recharges the surface water & the
    # fraction that flows out directly
    surface_runoff_direct = (o_one - rf) * overland_runoff

    # fraction of surface storage that flows out irrespective of input
    suw_recharge = rf * overland_runoff
    surface_runoff_indirect = dc * sum(surfaceW + ΔsurfaceW)

    # get the total surface runoff
    surface_runoff = surface_runoff_direct + surface_runoff_indirect

    # update the delta storage
    @add_to_elem suw_recharge → (ΔsurfaceW, 1, :surfaceW) # assumes all the recharge supplies the first surface water layer
    ΔsurfaceW = addToEachElem(ΔsurfaceW, - surface_runoff_indirect / n_surfaceW)

    ## pack land variables
    @pack_land begin
        (surface_runoff, surface_runoff_direct, surface_runoff_indirect, suw_recharge) → land.fluxes
        ΔsurfaceW → land.pools
    end
    return land
end

function update(params::runoffSurface_directIndirect, forcing, land, helpers)
    @unpack_runoffSurface_directIndirect params

    ## unpack variables
    @unpack_land begin
        surfaceW ∈ land.pools
        ΔsurfaceW ∈ land.pools
    end

    ## update storage pools
    surfaceW .= surfaceW .+ ΔsurfaceW

    # reset ΔsurfaceW to zero
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

    ## pack land variables
    @pack_land begin
        surfaceW → land.pools
        ΔsurfaceW → land.pools
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
