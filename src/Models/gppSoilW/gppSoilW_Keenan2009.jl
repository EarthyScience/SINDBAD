export gppSoilW_Keenan2009

#! format: off
@bounds @describe @units @with_kw struct gppSoilW_Keenan2009{T1,T2,T3} <: gppSoilW
    q::T1 = 0.6 | (0.0, 15.0) | "sensitivity of GPP to soil moisture " | ""
    f_s_max::T2 = 0.7 | (0.2, 1.0) | "" | ""
    f_s_min::T3 = 0.5 | (0.01, 0.95) | "" | ""
end
#! format: on

function compute(params::gppSoilW_Keenan2009, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Keenan2009 params

    ## unpack land variables
    @unpack_land begin
        (sum_wSat, sum_WP) ∈ land.soilWBase
        soilW ∈ land.pools
    end

    max_AWC = maxZero(sum_wSat - sum_WP)
    s_max = f_s_max * max_AWC
    s_min = f_s_min * s_max

    SM = max(sum(soilW), s_min)
    smsc = ((SM - s_min) / (s_max - s_min))^q
    gpp_f_soilW = clampZeroOne(smsc)

    ## pack land variables
    @pack_land gpp_f_soilW => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gpp_potential based on Keenan2009

# Parameters
$(SindbadParameters)

---

# compute:
Gpp as a function of soilW

*Inputs*
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.wSat: saturation point
 - land.soilWBase.WP: wilting point

*Outputs*
 - land.gppSoilW.gpp_f_soilW: soil moisture stress on gpp_potential (0-1)

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
