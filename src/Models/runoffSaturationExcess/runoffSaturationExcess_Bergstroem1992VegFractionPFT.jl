export runoffSaturationExcess_Bergstroem1992VegFractionPFT

#! format: off
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992VegFractionPFT{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13} <: runoffSaturationExcess
    β_PFT0::T1 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 0 to get the berg parameter from vegFrac" | ""
    β_PFT1::T2 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 1 to get the berg parameter from vegFrac" | ""
    β_PFT2::T3 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 2 to get the berg parameter from vegFrac" | ""
    β_PFT3::T4 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 3 to get the berg parameter from vegFrac" | ""
    β_PFT4::T5 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 4 to get the berg parameter from vegFrac" | ""
    β_PFT5::T6 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 5 to get the berg parameter from vegFrac" | ""
    β_PFT6::T7 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 6 to get the berg parameter from vegFrac" | ""
    β_PFT7::T8 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 7 to get the berg parameter from vegFrac" | ""
    β_PFT8::T9 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 8 to get the berg parameter from vegFrac" | ""
    β_PFT9::T10 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 9 to get the berg parameter from vegFrac" | ""
    β_PFT10::T11 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 10 to get the berg parameter from vegFrac" | ""
    β_PFT11::T12 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 11 to get the berg parameter from vegFrac" | ""
    β_min::T13 = 0.1 | (0.08, 0.120) | "minimum effective β" | ""
end
#! format: on

function define(p_struct::runoffSaturationExcess_Bergstroem1992VegFractionPFT, forcing, land, helpers)
    ## unpack parameters and forcing
    #@needscheck
    @unpack_runoffSaturationExcess_Bergstroem1992VegFractionPFT p_struct

    # get the PFT data & assign parameters
    β_veg = eval("β_PFT" * string(PFT))

    # get the berg parameters according the vegetation fraction
    β_veg = max(β_min, β_veg * frac_vegetation) # do this?

    ## pack land variables
    @pack_land begin
        β_veg => land.runoffSaturationExcess
    end
    return land
end

function compute(p_struct::runoffSaturationExcess_Bergstroem1992VegFractionPFT, forcing, land, helpers)
    ## unpack parameters and forcing
    #@needscheck
    @unpack_runoffSaturationExcess_Bergstroem1992VegFractionPFT p_struct
    @unpack_forcing PFT ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (WBP, frac_vegetation) ∈ land.states
        β_veg ∈ land.runoffSaturationExcess
        wSat ∈ land.soilWBase
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end
    # get the PFT data & assign parameters
    tmp_smax_veg = sum(wSat)
    tmp_soilW_total = sum(soilW + ΔsoilW)

    # calculate land runoff from incoming water & current soil moisture
    tmp_sat_exc_frac = minOne((tmp_soilW_total / tmp_smax_veg)^β_veg)
    sat_excess_runoff = WBP * tmp_sat_exc_frac
    # update water balance pool
    WBP = WBP - sat_excess_runoff

    ## pack land variables
    @pack_land begin
        sat_excess_runoff => land.fluxes
        WBP => land.states
    end
    return land
end

@doc """
saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and PFT

# Parameters
$(SindbadParameters)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992VegFractionPFT

*Inputs*
 - forcing.PFT : PFT classes
 - land.runoffSaturationExcess.p_berg_scale : scalar for land.states.frac_vegetation to define shape parameter of runoff-infiltration curve []
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
 - Bergström, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 10.09.2021 [ttraut]: based on runoffSaturation_BergstroemLinVegFr  
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
 - 1.1 on 27.11.2019 [skoirala]: changed to handle any number of soil layers
 - 1.2 on 10.02.2020 [ttraut]: modyfying variable name to match the new SINDBAD version

*Created by:*
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992VegFractionPFT
