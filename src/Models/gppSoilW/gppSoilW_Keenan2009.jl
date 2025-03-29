export gppSoilW_Keenan2009

#! format: off
@bounds @describe @units @timescale @with_kw struct gppSoilW_Keenan2009{T1,T2,T3} <: gppSoilW
    q::T1 = 0.6 | (0.0, 15.0) | "sensitivity of GPP to soil moisture " | "" | ""
    f_s_max::T2 = 0.7 | (0.2, 1.0) | "" | "" | ""
    f_s_min::T3 = 0.5 | (0.01, 0.95) | "" | "" | ""
end
#! format: on

function compute(params::gppSoilW_Keenan2009, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Keenan2009 params

    ## unpack land variables
    @unpack_nt begin
        (∑w_sat, ∑w_wp) ⇐ land.properties
        soilW ⇐ land.pools
    end

    max_AWC = maxZero(∑w_sat - ∑w_wp)
    s_max = f_s_max * max_AWC
    s_min = f_s_min * s_max

    SM = max(sum(soilW), s_min)
    smsc = ((SM - s_min) / (s_max - s_min))^q
    gpp_f_soilW = clampZeroOne(smsc)

    ## pack land variables
    @pack_nt gpp_f_soilW ⇒ land.diagnostics
    return land
end

purpose(::Type{gppSoilW_Keenan2009}) = "soil moisture stress on gpp_potential based on Keenan2009"

@doc """

$(getBaseDocString())

---

# Extended help

*References*
 - Keenan; T.; García; R.; Friend; A. D.; Zaehle; S.; Gracia  C.; & Sabate; S.: Improved understanding of drought  controls on seasonal variation in Mediterranean forest  canopy CO2 & water fluxes through combined in situ  measurements & ecosystem modelling; Biogeosciences; 6; 1423–1444

*Versions*
 - 1.0 on 10.03.2020 [sbesnard]  

*Created by:*
 - ncarvalhais & sbesnard

*Notes*
"""
gppSoilW_Keenan2009
