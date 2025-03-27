export runoffSurface_directIndirectFroSoil

#! format: off
@bounds @describe @units @timescale @with_kw struct runoffSurface_directIndirectFroSoil{T1,T2} <: runoffSurface
    dc::T1 = 0.01 | (0.0, 1.0) | "delayed surface runoff coefficient" | "" | ""
    rf::T2 = 0.5 | (0.0, 1.0) | "fraction of overland runoff that recharges the surface water storage" | "" | ""
end
#! format: on

function compute(params::runoffSurface_directIndirectFroSoil, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSurface_directIndirectFroSoil params

    ## unpack land variables
    @unpack_nt begin
        frac_frozen ⇐ land.runoffSaturationExcess
        surfaceW ⇐ land.pools
        ΔsurfaceW ⇐ land.pools
        overland_runoff ⇐ land.fluxes
        (z_zero, o_one) ⇐ land.constants
        n_surfaceW ⇐ land.constants
    end
    # fraction of overland runoff that flows out directly
    fracFastQ = (o_one - rf) * (o_one - frac_frozen) + frac_frozen

    surface_runoff_direct = fracFastQ * overland_runoff

    # fraction of surface storage that flows out irrespective of input
    suw_recharge = rf * overland_runoff
    surface_runoff_indirect = dc * sum(surfaceW + ΔsurfaceW)

    # get the total surface runoff
    surface_runoff = surface_runoff_direct + surface_runoff_indirect

    # update the delta storage
    ΔsurfaceW[1] = ΔsurfaceW[1] + suw_recharge # assumes all the recharge supplies the first surface water layer
    ΔsurfaceW .= ΔsurfaceW .- surface_runoff_indirect / n_surfaceW # assumes all layers contribute equally to indirect component of surface runoff

    ## pack land variables
    @pack_nt begin
        (surface_runoff, surface_runoff_direct, surface_runoff_indirect, suw_recharge) ⇒ land.fluxes
        ΔsurfaceW ⇒ land.pools
    end
    return land
end

function update(params::runoffSurface_directIndirectFroSoil, forcing, land, helpers)
    @unpack_runoffSurface_directIndirectFroSoil params

    ## unpack variables
    @unpack_nt begin
        surfaceW ⇐ land.pools
        ΔsurfaceW ⇐ land.pools
    end

    ## update storage pools
    surfaceW .= surfaceW .+ ΔsurfaceW

    # reset ΔsurfaceW to zero
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

    ## pack land variables
    @pack_nt begin
        surfaceW ⇒ land.pools
        ΔsurfaceW ⇒ land.pools
    end
    return land
end

@doc """
assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid

# Parameters
$(SindbadParameters)

---

# compute:
Runoff from surface water storages using runoffSurface_directIndirectFroSoil

*Inputs*
 - land.fluxes.overland_runoff
 - land.runoffSaturationExcess.frac_frozen

*Outputs*

# update

update pools and states in runoffSurface_directIndirectFroSoil


---

# Extended help

*References*

*Versions*
 - 1.0 on 03.12.2020 [ttraut]  

*Created by:*
 - ttraut
"""
runoffSurface_directIndirectFroSoil
