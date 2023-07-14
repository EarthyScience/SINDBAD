export runoffSaturationExcess_Zhang2008

#! format: off
@bounds @describe @units @with_kw struct runoffSaturationExcess_Zhang2008{T1} <: runoffSaturationExcess
    α::T1 = 0.5 | (0.01, 10.0) | "an empirical Budyko parameter" | ""
end
#! format: on

function compute(p_struct::runoffSaturationExcess_Zhang2008, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffSaturationExcess_Zhang2008 p_struct

    ## unpack land variables
    @unpack_land begin
        WBP ∈ land.states
        p_wSat ∈ land.soilWBase
        soilW ∈ land.pools
        PET ∈ land.PET
        ΔsoilW ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
    end
    # a supply - demand limit concept cf Budyko
    # calc demand limit [X0]
    res_sat = max_0(sum(p_wSat) - sum(soilW + ΔsoilW))
    X0 = PET + res_sat

    # set sat_excess_runoff
    sat_excess_runoff = WBP - WBP * (𝟙 + X0 / WBP - (𝟙 + (X0 / WBP)^(𝟙 / α))^α)
    # adjust the remaining water
    WBP = WBP - sat_excess_runoff

    ## pack land variables
    @pack_land begin
        sat_excess_runoff => land.fluxes
        WBP => land.states
    end
    return land
end

@doc """
saturation excess runoff as a function of incoming water and PET

# Parameters
$(PARAMFIELDS)

---

# compute:
Saturation runoff using runoffSaturationExcess_Zhang2008

*Inputs*
 - land.PET.PET: potential ET
 - land.soilWBase.p_wAWC: maximum available water in soil per layer
 - land.states.WBP: amount of incoming water

*Outputs*
 - land.fluxes.sat_excess_runoff: saturation excess runoff in mm/day
 - land.states.WBP

---

# Extended help

*References*
 - Zhang et al 2008; Water balance modeling over variable time scales  based on the Budyko framework ? Model development & testing; Journal of Hydrology
 - a combination of eq 14 & eq 15 in zhang et al 2008

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - mjung
 - skoirala

*Notes*
 - is supposed to work over multiple time scales. it represents the  "fast" | "direct" runoff & thus it"s conceptually not really  consistent with "saturation runoff". it basically lumps saturation runoff  & interflow; i.e. if using this approach for saturation runoff it would  be consistent to set interflow to none
 - supply limit is (land.states.WBP): Zhang et al use precipitation as supply limit. we here use precip +snow  melt - interception - infliltration excess runoff (i.e. the water that  arrives at the ground) - this is more consistent with the budyko logic  than just using precip
"""
runoffSaturationExcess_Zhang2008
