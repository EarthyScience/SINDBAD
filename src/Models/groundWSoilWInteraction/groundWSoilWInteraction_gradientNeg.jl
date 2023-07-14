export groundWSoilWInteraction_gradientNeg

#! format: off
@bounds @describe @units @with_kw struct groundWSoilWInteraction_gradientNeg{T1,T2} <: groundWSoilWInteraction
    smax_scale::T1 = 0.5 | (0.0, 50.0) | "scale param to yield storage capacity of wGW" | ""
    max_flux::T2 = 10.0 | (0.0, 20.0) | "maximum flux between wGW and wSoil" | "[mm d]"
end
#! format: on

function compute(p_struct::groundWSoilWInteraction_gradientNeg, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWSoilWInteraction_gradientNeg p_struct

    ## unpack land variables
    @unpack_land begin
        p_wSat ∈ land.soilWBase
        (groundW, soilW) ∈ land.pools
        (ΔsoilW, ΔgroundW) ∈ land.states
        n_groundW ∈ land.wCycleBase
        𝟘 ∈ helpers.numbers
    end
    # maximum groundwater storage
    p_gwmax = p_wSat[end] * smax_scale

    # gradient between groundW[1] & soilW
    tmp_gradient = sum(groundW + ΔgroundW) / p_gwmax - (soilW[end] + ΔsoilW[end]) / p_wSat[end] # the sign of the gradient gives direction of flow: positive = flux to soil; negative = flux to gw from soilW

    # scale gradient with pot flux rate to get pot flux
    pot_flux = tmp_gradient * max_flux # need to make sure that the flux does not overflow | underflow storages

    # adjust the pot flux to what is there
    tmp = min(pot_flux, p_wSat[end] - (soilW[end] + ΔsoilW[end]), sum(groundW + ΔgroundW))
    tmp = max(tmp, -(soilW[end] + ΔsoilW[end]), -sum(groundW + ΔgroundW))

    # -> set all the positive values (from groundwater to soil) to zero
    gw_capillary_flux = min_0(tmp)

    # adjust the delta storages
    ΔgroundW .= ΔgroundW .- gw_capillary_flux / n_groundW
    ΔsoilW[end] = ΔsoilW[end] + gw_capillary_flux

    ## pack land variables
    @pack_land begin
        gw_capillary_flux => land.fluxes
        (ΔsoilW, ΔgroundW) => land.states
    end
    return land
end

function update(p_struct::groundWSoilWInteraction_gradientNeg, forcing, land, helpers)

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
calculates a buffer storage that doesn't give water to the soil when the soil dries up; while the soil gives water to the groundW when the soil is wet but the groundW low; the groundW is only recharged by soil moisture

# Parameters
$(PARAMFIELDS)

---

# compute:
Groundwater soil moisture interactions (capilary flux) using groundWSoilWInteraction_gradientNeg

*Inputs*
 - info : length(land.pools.soilW) = number of soil layers
 - land.groundWSoilWInteraction.p_gwmax : maximum storage capacity of the groundwater
 - land.soilWBase.p_wSat : maximum storage capacity of soil [mm]

*Outputs*
 - land.fluxes.gw_capillary_flux : flux between groundW & soilW

# update
update pools and states in groundWSoilWInteraction_gradientNeg=
 - land.pools.groundW
 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 04.02.2020 [ttraut]
 - 1.0 on 23.09.2020 [ttraut]

*Created by:*
 - ttraut
"""
groundWSoilWInteraction_gradientNeg
