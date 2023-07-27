export runoffSaturationExcess_Bergstroem1992MixedVegFraction

#! format: off
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992MixedVegFraction{T1,T2,T3} <: runoffSaturationExcess
    βV::T1 = 5.0 | (0.1, 20.0) | "linear scaling parameter for berg for vegetated fraction" | ""
    βS::T2 = 2.0 | (0.1, 20.0) | "linear scaling parameter for berg for non vegetated fraction" | ""
    β_min::T3 = 0.1 | (0.08, 0.120) | "minimum effective β" | ""
end
#! format: on

function compute(p_struct::runoffSaturationExcess_Bergstroem1992MixedVegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSaturationExcess_Bergstroem1992MixedVegFraction p_struct

    ## unpack land variables
    @unpack_land begin
        (WBP, frac_vegetation) ∈ land.states
        wSat ∈ land.soilWBase
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
    end
    tmp_smaxVeg = sum(wSat)
    tmp_SoilTotal = sum(soilW + ΔsoilW)

    # get the berg parameters according the vegetation fraction
    β_veg = βV * frac_vegetation + βS * (o_one - frac_vegetation)
    β_veg = max(β_min, berg) # do this?

    # calculate land runoff from incoming water & current soil moisture
    tmp_SatExFrac = clamp_01((tmp_SoilTotal / tmp_smaxVeg)^β_veg)
    sat_excess_runoff = WBP * tmp_SatExFrac

    # update water balance
    WBP = WBP - sat_excess_runoff

    ## pack land variables
    @pack_land begin
        sat_excess_runoff => land.fluxes
        WBP => land.states
    end
    return land
end

@doc """
saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions

# Parameters
$(PARAMFIELDS)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992MixedVegFraction

*Inputs*
 - berg : shape parameter of runoff-infiltration curve []

*Outputs*
 - land.fluxes.sat_excess_runoff : runoff from land [mm/time]
 - land.states.WBP : water balance pool [mm]

---

# Extended help

*References*
 - Bergström, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - 1.1 on 27.11.2019: skoirala: changed to handle any number of soil layers
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992MixedVegFraction
