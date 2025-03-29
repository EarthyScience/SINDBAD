export capillaryFlow_VanDijk2010

#! format: off
@bounds @describe @units @timescale @with_kw struct capillaryFlow_VanDijk2010{T1} <: capillaryFlow
    max_frac::T1 = 0.95 | (0.02, 0.98) | "max fraction of soil moisture that can be lost as capillary flux" | "" | ""
end
#! format: on

function define(params::capillaryFlow_VanDijk2010, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        soilW ⇐ land.pools
    end
    soil_capillary_flux = zero(soilW)

    ## pack land variables
    @pack_nt begin
        soil_capillary_flux ⇒ land.fluxes
    end
    return land
end

function compute(params::capillaryFlow_VanDijk2010, forcing, land, helpers)
    ## unpack parameters
    @unpack_capillaryFlow_VanDijk2010 params

    ## unpack land variables
    @unpack_nt begin
        (k_fc, w_sat) ⇐ land.properties
        soil_capillary_flux ⇐ land.fluxes
        (soilW, ΔsoilW) ⇐ land.pools
        tolerance ⇐ helpers.numbers
        (z_zero, o_one) ⇐ land.constants
    end

    for sl ∈ 1:(length(soilW)-1)
        dos_soilW = clampZeroOne((soilW[sl] + ΔsoilW[sl]) ./ w_sat[sl])
        tmpCapFlow = sqrt(k_fc[sl+1] * k_fc[sl]) * (o_one - dos_soilW)
        holdCap = maxZero(w_sat[sl] - (soilW[sl] + ΔsoilW[sl]))
        lossCap = maxZero(max_frac * (soilW[sl+1] + ΔsoilW[sl+1]))
        minFlow = min(tmpCapFlow, holdCap, lossCap)
        tmp = minFlow > tolerance ? minFlow : zero(minFlow)
        @rep_elem tmp ⇒ (soil_capillary_flux, sl, :soilW)
        @add_to_elem soil_capillary_flux[sl] ⇒ (ΔsoilW, sl, :soilW)
        @add_to_elem -soil_capillary_flux[sl] ⇒ (ΔsoilW, sl + 1, :soilW)
    end

    ## pack land variables
    @pack_nt begin
        soil_capillary_flux ⇒ land.fluxes
        ΔsoilW ⇒ land.pools
    end
    return land
end

function update(params::capillaryFlow_VanDijk2010, forcing, land, helpers)

    ## unpack variables
    @unpack_nt begin
        (soilW, ΔsoilW) ⇐ land.pools
    end

    ## update variables
    # update soil moisture of the first layer
    soilW = soilW + ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW = ΔsoilW - ΔsoilW

    ## pack land variables
    @pack_nt begin
        (soilW, ΔsoilW) ⇒ land.pools
    end
    return land
end

purpose(::Type{capillaryFlow_VanDijk2010}) = "computes the upward water flow in the soil layers"

@doc """

$(getBaseDocString(capillaryFlow_VanDijk2010))

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
