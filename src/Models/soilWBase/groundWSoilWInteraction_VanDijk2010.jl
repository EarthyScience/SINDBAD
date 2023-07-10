export groundWSoilWInteraction_VanDijk2010

#! format: off
@bounds @describe @units @with_kw struct groundWSoilWInteraction_VanDijk2010{T1} <: groundWSoilWInteraction
    max_fraction::T1 = 0.5 | (0.001, 0.98) | "fraction of groundwater that can be lost to capillary flux" | ""
end
#! format: on

function define(p_struct::groundWSoilWInteraction_VanDijk2010, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        𝟘 ∈ helpers.numbers
    end

    # calculate recharge
    gw_capillary_flux = 𝟘
    ## pack land variables
    @pack_land begin
        gw_capillary_flux => land.fluxes
    end
    return land
end

function compute(p_struct::groundWSoilWInteraction_VanDijk2010, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWSoilWInteraction_VanDijk2010 p_struct

    ## unpack land variables
    @unpack_land begin
        (p_kFC, p_kSat, p_wSat) ∈ land.soilWBase
        (groundW, soilW) ∈ land.pools
        (ΔsoilW, ΔgroundW) ∈ land.states
        unsatK ∈ land.soilProperties
        (𝟘, 𝟙) ∈ helpers.numbers
        zero(land.pools.soilW) ∈ land.wCycleBase
    end

    # calculate recharge
    # degree of saturation & unsaturated hydraulic conductivity of the lowermost soil layer
    dosSoilend = clamp_01((soilW[end] + ΔsoilW[end]) / p_wSat[end])
    k_sat = p_kSat[end] # assume GW is saturated
    k_fc = p_kFC[end] # assume GW is saturated
    k_unsat = unsatK(land, helpers, lastindex(land.pools.soilW))

    # get the capillary flux
    c_flux = sqrt(k_unsat * k_sat) * (𝟙 - dosSoilend)
    gw_capillary_flux = max_0(min(c_flux, max_fraction * (sum(groundW) + sum(ΔgroundW)),
        soilW[end] + ΔsoilW[end]))

    # adjust the delta storages
    ΔgroundW = add_to_each_elem(ΔgroundW, -gw_capillary_flux / zero(land.pools.soilW))
    @add_to_elem gw_capillary_flux => (ΔsoilW, lastindex(ΔsoilW), :soilW)

    ## pack land variables
    @pack_land begin
        gw_capillary_flux => land.fluxes
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
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.

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
