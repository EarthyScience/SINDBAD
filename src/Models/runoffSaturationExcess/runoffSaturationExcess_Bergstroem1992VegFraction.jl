export runoffSaturationExcess_Bergstroem1992VegFraction

#! format: off
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992VegFraction{T1,T2} <: runoffSaturationExcess
    β::T1 = 3.0 | (0.1, 10.0) | "linear scaling parameter to get the berg parameter from vegFrac" | ""
    β_min::T2 = 0.1 | (0.08, 0.120) | "minimum effective β" | ""
end
#! format: on

function compute(p_struct::runoffSaturationExcess_Bergstroem1992VegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSaturationExcess_Bergstroem1992VegFraction p_struct

    ## unpack land variables
    @unpack_land begin
        (WBP, frac_vegetation) ∈ land.states
        wSat ∈ land.soilWBase
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end
    tmp_smaxVeg = sum(wSat)
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
        β_veg => land.runoffSaturationExcess
        WBP => land.states
    end
    return land
end

@doc """
saturation excess runoff using Bergström method with parameter scaled by vegetation fraction

# Parameters
$(SindbadParameters)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992VegFraction

*Inputs*
 - land.states.frac_vegetation : vegetation fraction
 - smax1 : maximum water capacity of first soil layer [mm]
 - smax2 : maximum water capacity of second soil layer [mm]

*Outputs*
 - land.fluxes.sat_excess_runoff : runoff from land [mm/time]
 - land.runoffSaturationExcess.p_berg : scaled berg parameter
 - land.states.WBP : water balance pool [mm]

---

# Extended help

*References*
 - Bergström, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
 - 1.1 on 27.11.2019 [skoirala]: changed to handle any number of soil layers
 - 1.2 on 10.02.2020 [ttraut]: modyfying variable name to match the new SINDBAD version

*Created by:*
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992VegFraction
