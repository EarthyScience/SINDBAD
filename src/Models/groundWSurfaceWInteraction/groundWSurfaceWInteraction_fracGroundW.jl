export groundWSurfaceWInteraction_fracGroundW

#! format: off
@bounds @describe @units @with_kw struct groundWSurfaceWInteraction_fracGroundW{T1} <: groundWSurfaceWInteraction
    k_groundW_to_surfaceW::T1 = 0.5 | (0.0001, 0.999) | "scale parameter for drainage from wGW to wSurf" | "fraction"
end
#! format: on

function compute(params::groundWSurfaceWInteraction_fracGroundW, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWSurfaceWInteraction_fracGroundW params

    ## unpack land variables
    @unpack_land begin
        (groundW, surfaceW) ∈ land.pools
        (ΔsurfaceW, ΔgroundW) ∈ land.pools
        (n_surfaceW, n_groundW) ∈ land.constants
    end

    ## calculate variables
    groundW_to_surfaceW = k_groundW_to_surfaceW * totalS(groundW, ΔgroundW)

    # update the delta storages
    ΔgroundW = addToEachElem(ΔgroundW, -groundW_to_surfaceW / n_groundW)
    ΔsurfaceW = addToEachElem(ΔsurfaceW, groundW_to_surfaceW / n_surfaceW)

    ## pack land variables
    @pack_land begin
        groundW_to_surfaceW → land.fluxes
        (ΔsurfaceW, ΔgroundW) → land.pools
    end
    return land
end

function update(params::groundWSurfaceWInteraction_fracGroundW, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, surfaceW) ∈ land.pools
        (ΔgroundW, ΔsurfaceW) ∈ land.states
    end

    ## update storage pools
    surfaceW .= surfaceW .+ ΔsurfaceW
    groundW .= groundW .+ ΔgroundW

    # reset ΔgroundW and ΔsurfaceW to zero
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW
    ΔgroundW .= ΔgroundW .- ΔgroundW

    ## pack land variables
    @pack_land begin
        (groundW, ΔgroundW, surfaceW, ΔsurfaceW) → land.pools
    end
    return land
end

@doc """
calculates the depletion of groundwater to the surface water as a fraction of groundwater storage

# Parameters
$(SindbadParameters)

---

# compute:
Water exchange between surface and groundwater using groundWSurfaceWInteraction_fracGroundW

*Inputs*
 - land.pools.groundW: groundwater storage
 - land.pools.surfaceW: surface water storage
 - land.surface_runoff.dc: drainage parameter from surfaceW

*Outputs*
 - land.fluxes.groundW2surfaceW: groundW to surfaceW [always positive]

# update

update pools and states in groundWSurfaceWInteraction_fracGroundW

 - land.pools.groundW
 - land.pools.surfaceW

---

# Extended help

*References*

*Versions*
 - 1.0 on 04.02.2020 [ttraut]

*Created by:*
 - ttraut
"""
groundWSurfaceWInteraction_fracGroundW
