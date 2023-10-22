export groundWSoilWInteraction_gradient

#! format: off
@bounds @describe @units @with_kw struct groundWSoilWInteraction_gradient{T1,T2} <: groundWSoilWInteraction
    smax_scale::T1 = 0.5 | (0.0, 50.0) | "scale param to yield storage capacity of wGW" | ""
    max_flux::T2 = 10.0 | (0.0, 20.0) | "maximum flux between wGW and wSoil" | "[mm d]"
end
#! format: on


function define(params::groundWSoilWInteraction_gradient, forcing, land, helpers)
    @unpack_land z_zero ∈ land.constants
    ## in case groundWReacharge is not selected in the model structure, instantiate the variable with zero
    gw_recharge = z_zero
    ## pack land variables
    @pack_land gw_recharge → land.fluxes
    return land
end

function compute(params::groundWSoilWInteraction_gradient, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWSoilWInteraction_gradient params
    ## unpack land variables
    @unpack_land begin
        wSat ∈ land.properties
        (ΔsoilW, soilW, ΔgroundW, groundW) ∈ land.pools
        (n_groundW, z_zero) ∈ land.constants
        gw_recharge ∈ land.fluxes
    end
    # maximum groundwater storage
    p_gwmax = wSat[end] * smax_scale

    total_soilW = soilW[end] + ΔsoilW[end]
    total_groundW = totalS(groundW, ΔgroundW)

    # gradient between groundW[1] & soilW
    tmp_gradient = total_groundW / p_gwmax - total_soilW / wSat[end] # the sign of the gradient gives direction of flow: positive = flux to soil; negative = flux to gw from soilW

    # scale gradient with pot flux rate to get pot flux
    pot_flux = tmp_gradient * max_flux # need to make sure that the flux does not overflow | underflow storages

    # adjust the pot flux to what is there
    tmp = min(pot_flux, wSat[end] - total_soilW, total_groundW)
    gw_capillary_flux = max(tmp, -total_soilW, -total_groundW)

    # adjust the delta storages
    ΔgroundW = addToEachElem(ΔgroundW, -gw_capillary_flux / n_groundW)
    @add_to_elem gw_capillary_flux → (ΔsoilW, lastindex(ΔsoilW), :soilW)

    # adjust the gw_recharge as net flux between soil and groundwater. positive from soil to gw
    gw_recharge = gw_recharge - gw_capillary_flux

    ## pack land variables
    @pack_land begin
        (gw_capillary_flux, gw_recharge) → land.fluxes
        (ΔsoilW, ΔgroundW) → land.pools
    end
    return land
end

function update(params::groundWSoilWInteraction_gradient, forcing, land, helpers)
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
        (groundW, soilW) → land.pools
        (ΔsoilW, ΔgroundW) → land.pools
    end
    return land
end

@doc """
calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low

# Parameters
$(SindbadParameters)

---

# compute:
Groundwater soil moisture interactions (capilary flux) using groundWSoilWInteraction_gradient

*Inputs*
 - info : length(land.pools.soilW) = number of soil layers
 - land.groundWSoilWInteraction.p_gwmax : maximum storage capacity of the groundwater
 - land.properties.wSat : maximum storage capacity of soil [mm]

*Outputs*
 - land.fluxes.GW2Soil : flux between groundW & soilW (positive from groundwater to soil, and negative from soil to groundwater)

# update

update pools and states in groundWSoilWInteraction_gradient

 - land.pools.groundW
 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 04.02.2020 [ttraut]

*Created by:*
 - ttraut
"""
groundWSoilWInteraction_gradient
