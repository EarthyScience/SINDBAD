export gppSoilW_GSI

#! format: off
@bounds @describe @units @with_kw struct gppSoilW_GSI{T1,T2,T3,T4} <: gppSoilW
    fW_τ::T1 = 0.8 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
    fW_slope::T2 = 5.24 | (1.0, 10.0) | "slope of sigmoid" | "fraction"
    fW_slope_mult::T3 = 100.0 | (nothing, nothing) | "multiplier for the slope of sigmoid" | "fraction"
    fW_base::T4 = 0.2096 | (0.1, 0.8) | "base of sigmoid" | "fraction"
end
#! format: on

function define(p_struct::gppSoilW_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_GSI p_struct

    gpp_f_soilW_prev = o_one

    ## pack land variables
    @pack_land (gpp_f_soilW_prev) => land.gppSoilW
    return land
end

function compute(p_struct::gppSoilW_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_GSI p_struct

    ## unpack land variables
    @unpack_land begin
        (s_wAWC, s_wWP) ∈ land.soilWBase
        soilW ∈ land.pools
        (gpp_f_soilW_prev) ∈ land.gppSoilW
        (z_zero, o_one) ∈ land.wCycleBase
    end

    actAWC = max_0(addS(soilW) - s_wWP)
    SM_nor = min_1(actAWC / s_wAWC)
    gpp_f_soilW = (o_one - fW_τ) * gpp_f_soilW_prev + fW_τ * (o_one / (o_one + exp(-fW_slope * (SM_nor - fW_base))))
    gpp_f_soilW = clamp_01(gpp_f_soilW)
    gpp_f_soilW_prev = gpp_f_soilW

    ## pack land variables
    @pack_land (gpp_f_soilW, gpp_f_soilW_prev) => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gpp_potential based on GSI implementation of LPJ

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - fW_τ: contribution of current time step
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point

*Outputs*
 - land.gppSoilW.gpp_f_soilW: soil moisture stress on gpp_potential (0-1)

---

# Extended help

*References*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions*
 - 1.1 on 22.01.2021 [skoirala]

*Created by:*
 - skoirala

*Notes*
"""
gppSoilW_GSI
