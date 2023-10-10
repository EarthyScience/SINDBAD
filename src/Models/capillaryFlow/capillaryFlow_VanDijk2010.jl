export capillaryFlow_VanDijk2010

#! format: off
@bounds @describe @units @with_kw struct capillaryFlow_VanDijk2010{T1} <: capillaryFlow
    max_frac::T1 = 0.95 | (0.02, 0.98) | "max fraction of soil moisture that can be lost as capillary flux" | ""
end
#! format: on

function define(p_struct::capillaryFlow_VanDijk2010, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
    end
    soil_capillary_flux = zero(soilW)

    ## pack land variables
    @pack_land begin
        soil_capillary_flux => land.fluxes
    end
    return land
end

function compute(p_struct::capillaryFlow_VanDijk2010, forcing, land, helpers)
    ## unpack parameters
    @unpack_capillaryFlow_VanDijk2010 p_struct

    ## unpack land variables
    @unpack_land begin
        (soil_kFC, wSat) ∈ land.soilWBase
        soil_capillary_flux ∈ land.fluxes
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        tolerance ∈ helpers.numbers
        (z_zero, o_one) ∈ land.wCycleBase
    end

    for sl ∈ 1:(length(soilW)-1)
        dos_soilW = clampZeroOne((soilW[sl] + ΔsoilW[sl]) ./ wSat[sl])
        tmpCapFlow = sqrt(soil_kFC[sl+1] * soil_kFC[sl]) * (o_one - dos_soilW)
        holdCap = maxZero(wSat[sl] - (soilW[sl] + ΔsoilW[sl]))
        lossCap = maxZero(max_frac * (soilW[sl+1] + ΔsoilW[sl+1]))
        minFlow = min(tmpCapFlow, holdCap, lossCap)
        tmp = minFlow > tolerance ? minFlow : zero(minFlow)
        @rep_elem tmp => (soil_capillary_flux, sl, :soilW)
        @add_to_elem soil_capillary_flux[sl] => (ΔsoilW, sl, :soilW)
        @add_to_elem -soil_capillary_flux[sl] => (ΔsoilW, sl + 1, :soilW)
    end

    ## pack land variables
    @pack_land begin
        soil_capillary_flux => land.fluxes
        ΔsoilW => land.states
    end
    return land
end

function update(p_struct::capillaryFlow_VanDijk2010, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end

    ## update variables
    # update soil moisture of the first layer
    soilW = soilW + ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW = ΔsoilW - ΔsoilW

    ## pack land variables
    @pack_land begin
        soilW => land.pools
        # ΔsoilW => land.states
    end
    return land
end

@doc """
computes the upward water flow in the soil layers

---

# compute:
Flux of water from lower to upper soil layers (upward soil moisture movement) using capillaryFlow_VanDijk2010

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conduct.

*Outputs*

# update

update pools and states in capillaryFlow_VanDijk2010

 - land.pools.soilW
 - land.states.soilWFlow: drainage flux between soil layers [from soilWRec] is adjusted to reflect  upward capillary flux

---

# Extended help

*References*
 - AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
 - http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
capillaryFlow_VanDijk2010
