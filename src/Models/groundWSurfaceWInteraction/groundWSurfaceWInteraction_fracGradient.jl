export groundWSurfaceWInteraction_fracGradient

#! format: off
@bounds @describe @units @with_kw struct groundWSurfaceWInteraction_fracGradient{T1} <: groundWSurfaceWInteraction
    k_groundW_to_surfaceW::T1 = 0.001 | (0.0001, 0.01) | "maximum transfer rate between GW and surface water" | "/d"
end
#! format: on

function compute(params::groundWSurfaceWInteraction_fracGradient, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWSurfaceWInteraction_fracGradient params

    ## unpack land variables
    @unpack_land begin
        (ΔsurfaceW, ΔgroundW, groundW, surfaceW) ∈ land.pools
        (n_surfaceW, n_groundW) ∈ land.constants
    end

    ## calculate variables
    tmp = k_groundW_to_surfaceW * (totalS(groundW, ΔgroundW) - totalS(surfaceW, ΔsurfaceW))

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

function update(params::groundWSurfaceWInteraction_fracGradient, forcing, land, helpers)
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
calculates the moisture exchange between groundwater & surface water as a fraction of difference between the storages

# Parameters
$(SindbadParameters)

---

# compute:
Water exchange between surface and groundwater using groundWSurfaceWInteraction_fracGradient

*Inputs*
 - land.pools.groundW: groundwater storage
 - land.pools.surfaceW: surface water storage

*Outputs*
 - land.fluxes.groundW2surfaceW:
 - negative: surfaceW to groundW
 - positive: groundW to surfaceW

# update

update pools and states in groundWSurfaceWInteraction_fracGradient

 - land.pools.groundW
 - land.pools.surfaceW

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
groundWSurfaceWInteraction_fracGradient
