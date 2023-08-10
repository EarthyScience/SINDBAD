export runoffSaturationExcess_Bergstroem1992VegFractionFroSoil

#! format: off
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992VegFractionFroSoil{T1,T2,T3} <: runoffSaturationExcess
    β::T1 = 3.0 | (0.1, 10.0) | "linear scaling parameter to get the berg parameter from vegFrac" | ""
    scaleFro::T2 = 1.0 | (0.1, 3.0) | "linear scaling parameter for rozen Soil fraction" | ""
    β_min::T3 = 0.1 | (0.08, 0.120) | "minimum effective β" | ""
end
#! format: on

function compute(p_struct::runoffSaturationExcess_Bergstroem1992VegFractionFroSoil, forcing, land, helpers)
    ## unpack parameters and forcing
    #@needscheck
    @unpack_runoffSaturationExcess_Bergstroem1992VegFractionFroSoil p_struct
    @unpack_forcing frac_frozen_soil ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (WBP, frac_vegetation) ∈ land.states
        wSat ∈ land.soilWBase
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
    end

    # scale the input frozen soil fraction; maximum is 1
    fracFrozen = minOne(frac_frozen_soil * scaleFro)
    tmp_smaxVeg = sum(wSat) * (o_one - fracFrozen + tolerance)
    tmp_SoilTotal = sum(soilW + ΔsoilW)

    # get the berg parameters according the vegetation fraction
    β_veg = max(β_min, β * frac_vegetation) # do this?

    # calculate land runoff from incoming water & current soil moisture
    tmp_SatExFrac = clampZeroOne((tmp_SoilTotal / tmp_smaxVeg)^β_veg)
    sat_excess_runoff = WBP * tmp_SatExFrac

    # update water balance pool
    WBP = WBP - sat_excess_runoff

    ## pack land variables
    @pack_land begin
        sat_excess_runoff => land.fluxes
        (fracFrozen, β_veg) => land.runoffSaturationExcess
        WBP => land.states
    end
    return land
end

@doc """
saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and frozen soil fraction

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - forcing.fracFrozen : daily frozen soil fraction [0-1]
 - land.fracFrozen.scale : scaling parameter for frozen soil fraction
 - land.runoffSaturationExcess.fracFrozen : scaled frozen soil fraction
 - land.states.frac_vegetation : vegetation fraction
 - smax1 : maximum water capacity of first soil layer [mm]
 - smax2 : maximum water capacity of second soil layer [mm]

*Outputs*
 - land.fluxes.sat_excess_runoff : runoff from land [mm/time]
 - land.runoffSaturationExcess.β_veg : scaled berg parameter
 - land.states.WBP : water balance pool [mm]

---

# Extended help

*References*
 - Bergstroem, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 18.11.2019 [ttraut]  

*Created by:*
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992VegFractionFroSoil
