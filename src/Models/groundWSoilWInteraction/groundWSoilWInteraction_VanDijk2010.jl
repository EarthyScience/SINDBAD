export groundWSoilWInteraction_VanDijk2010

#! format: off
@bounds @describe @units @with_kw struct groundWSoilWInteraction_VanDijk2010{T1} <: groundWSoilWInteraction
    max_fraction::T1 = 0.5 | (0.001, 0.98) | "fraction of groundwater that can be lost to capillary flux" | ""
end
#! format: on

function compute(p_struct::groundWSoilWInteraction_VanDijk2010, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWSoilWInteraction_VanDijk2010 p_struct

    ## unpack land variables
    @unpack_land begin
        (soil_kFC, kSat, wSat) ∈ land.soilWBase
        (groundW, soilW) ∈ land.pools
        (ΔsoilW, ΔgroundW) ∈ land.states
        unsat_k_model ∈ land.soilProperties
        (z_zero, o_one) ∈ land.wCycleBase
        n_groundW ∈ land.wCycleBase
        gw_recharge ∈ land.fluxes
    end

    # calculate recharge
    # degree of saturation & unsaturated hydraulic conductivity of the lowermost soil layer
    dosSoilend = clampZeroOne((soilW[end] + ΔsoilW[end]) / wSat[end])
    k_sat = kSat[end] # assume GW is saturated
    k_fc = soil_kFC[end] # assume GW is saturated
    k_unsat = unsatK(land, helpers, lastindex(land.pools.soilW), unsat_k_model)

    # get the capillary flux
    c_flux = sqrt(k_unsat * k_sat) * (o_one - dosSoilend)
    gw_capillary_flux = maxZero(min(c_flux, max_fraction * (sum(groundW) + sum(ΔgroundW)),
        soilW[end] + ΔsoilW[end]))

    # adjust the delta storages
    ΔgroundW = addToEachElem(ΔgroundW, -gw_capillary_flux / n_groundW)
    @add_to_elem gw_capillary_flux => (ΔsoilW, lastindex(ΔsoilW), :soilW)

    # adjust the gw_recharge as net flux between soil and groundwater. positive from soil to gw
    gw_recharge = gw_recharge - gw_capillary_flux

    ## pack land variables
    @pack_land begin
        (gw_capillary_flux, gw_recharge) => land.fluxes
        (ΔsoilW, ΔgroundW) => land.states
    end
    return land
end

function update(p_struct::groundWSoilWInteraction_VanDijk2010, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        (soilW, groundW) ∈ land.pools
        (ΔsoilW, ΔgroundW) ∈ land.states
    end

    ## update storage pools
    soilW[end] = soilW[end] + ΔsoilW[end]
    groundW .= groundW .+ ΔgroundW

    # reset ΔsoilW[end] and ΔgroundW to zero
    ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
    ΔgroundW .= ΔgroundW .- ΔgroundW

    ## pack land variables
    @pack_land begin
        (groundW, soilW) => land.pools
        (ΔsoilW, ΔgroundW) => land.states
    end
    return land
end

@doc """
calculates the upward flow of water from groundwater to lowermost soil layer using VanDijk method

---

# compute:
Groundwater soil moisture interactions (capilary flux) using groundWSoilWInteraction_VanDijk2010

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conduct.

*Outputs*
 - land.fluxes.gw_capillary_flux: capillary flux
 - land.fluxes.gw_recharge: net groundwater recharge

# update

update pools and states in groundWSoilWInteraction_VanDijk2010

 - land.fluxes.gw_recharge
 - land.pools.groundW[1]
 - land.pools.soilW

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
groundWSoilWInteraction_VanDijk2010
