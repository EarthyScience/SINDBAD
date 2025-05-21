export gppSoilW_GSI

#! format: off
@bounds @describe @units @timescale @with_kw struct gppSoilW_GSI{T1,T2,T3,T4} <: gppSoilW
    f_soilW_τ::T1 = 0.8 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction" | ""
    f_soilW_slope::T2 = 5.24 | (1.0, 10.0) | "slope of sigmoid" | "fraction" | ""
    f_soilW_slope_mult::T3 = 100.0 | (-Inf, Inf) | "multiplier for the slope of sigmoid" | "fraction" | ""
    f_soilW_base::T4 = 0.2096 | (0.1, 0.8) | "base of sigmoid" | "fraction" | ""
end
#! format: on

function define(params::gppSoilW_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_GSI params

    gpp_f_soilW_prev = one(f_soilW_τ)

    ## pack land variables
    @pack_nt (gpp_f_soilW_prev) ⇒ land.diagnostics
    return land
end

function compute(params::gppSoilW_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_GSI params

    ## unpack land variables
    @unpack_nt begin
        (∑w_awc, ∑w_wp) ⇐ land.properties
        soilW ⇐ land.pools
        (gpp_f_soilW_prev) ⇐ land.diagnostics
    end

    actAWC = maxZero(totalS(soilW) - ∑w_wp)
    SM_nor = minOne(actAWC / ∑w_awc)
    o_one = one(f_soilW_τ)
    gpp_f_soilW = (o_one - f_soilW_τ) * gpp_f_soilW_prev + f_soilW_τ * (o_one / (o_one + exp(-f_soilW_slope * (SM_nor - f_soilW_base))))
    gpp_f_soilW = clampZeroOne(gpp_f_soilW)
    gpp_f_soilW_prev = gpp_f_soilW

    ## pack land variables
    @pack_nt (gpp_f_soilW, gpp_f_soilW_prev) ⇒ land.diagnostics
    return land
end

purpose(::Type{gppSoilW_GSI}) = "soil moisture stress on gpp_potential based on GSI implementation of LPJ"

@doc """

$(getModelDocString(gppSoilW_GSI))

---

# Extended help

*References*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions*
 - 1.1 on 22.01.2021 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko

*Notes*
"""
gppSoilW_GSI
