export gppSoilW_Keenan2009

@bounds @describe @units @with_kw struct gppSoilW_Keenan2009{T1,T2,T3} <: gppSoilW
    q::T1 = 0.6 | (0.0, 15.0) | "sensitivity of GPP to soil moisture " | ""
    sSmax::T2 = 0.7 | (0.2, 1.0) | "" | ""
    sSmin::T3 = 0.5 | (0.01, 0.95) | "" | ""
end

function compute(o::gppSoilW_Keenan2009, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Keenan2009 o

    ## unpack land variables
    @unpack_land begin
        (s_wSat, s_wWP) ∈ land.soilWBase
        soilW ∈ land.pools
        (zero, one) ∈ helpers.numbers
    end

    maxAWC = max(s_wSat - s_wWP, zero)
    Smax = sSmax * maxAWC
    Smin = sSmin * Smax

    SM = max(sum(soilW), Smin)
    smsc = ((SM - Smin) / (Smax - Smin))^q
    SMScGPP = clamp(smsc, zero, one)

    ## pack land variables
    @pack_land SMScGPP => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gppPot based on Keenan2009

# Parameters
$(PARAMFIELDS)

---

# compute:
Gpp as a function of soilW

*Inputs*
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wSat: saturation point
 - land.soilWBase.p_wWP: wilting point

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture stress on gppPot (0-1)

---

# Extended help

*References*
 - Keenan; T.; García; R.; Friend; A. D.; Zaehle; S.; Gracia  C.; & Sabate; S.: Improved understanding of drought  controls on seasonal variation in Mediterranean forest  canopy CO2 & water fluxes through combined in situ  measurements & ecosystem modelling; Biogeosciences; 6; 1423–1444

*Versions*
 - 1.0 on 10.03.2020 [sbesnard]  

*Created by:*
 - ncarval & sbesnard

*Notes*
"""
gppSoilW_Keenan2009