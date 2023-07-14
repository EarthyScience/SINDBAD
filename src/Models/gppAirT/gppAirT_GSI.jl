export gppAirT_GSI

#! format: off
@bounds @describe @units @with_kw struct gppAirT_GSI{T1,T2,T3,T4,T5,T6} <: gppAirT
    fT_c_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor for cold stress" | "fraction"
    fT_c_slope::T2 = 0.25 | (0.0, 100.0) | "slope of sigmoid for cold stress" | "fraction"
    fT_c_base::T3 = 7.0 | (1.0, 15.0) | "base of sigmoid for cold stress" | "fraction"
    fT_h_τ::T4 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor for heat stress" | "fraction"
    fT_h_slope::T5 = 1.74 | (0.0, 100.0) | "slope of sigmoid for heat stress" | "fraction"
    fT_h_base::T6 = 41.51 | (25.0, 65.0) | "base of sigmoid for heat stress" | "fraction"
end
#! format: on

function define(p_struct::gppAirT_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppAirT_GSI p_struct
    @unpack_land 𝟙 ∈ helpers.numbers

    gpp_f_airT_c = 𝟙
    gpp_f_airT_h = 𝟙
    f_smooth =
        (f_p, f_n, τ, slope, base) -> (𝟙 - τ) * f_p +
                                      τ * (𝟙 / (𝟙 + exp(-slope * (f_n - base))))

    ## pack land variables
    @pack_land (gpp_f_airT_c, gpp_f_airT_h, f_smooth) => land.gppAirT
    return land
end

function compute(p_struct::gppAirT_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_GSI p_struct
    @unpack_forcing Tair ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (gpp_f_airT_c, gpp_f_airT_h, f_smooth) ∈ land.gppAirT
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    ## calculate variables
    f_c_prev = gpp_f_airT_c
    fT_c = f_smooth(f_c_prev, Tair, fT_c_τ, fT_c_slope, fT_c_base)
    cScGPP = clamp_01(fT_c)

    f_h_prev = gpp_f_airT_h
    fT_h = f_smooth(f_h_prev, Tair, fT_h_τ, -fT_h_slope, fT_h_base)
    hScGPP = clamp_01(fT_h)

    gpp_f_airT = min(cScGPP, hScGPP)

    gpp_f_airT_c = cScGPP
    gpp_f_airT_h = hScGPP

    ## pack land variables
    @pack_land (gpp_f_airT, cScGPP, hScGPP, gpp_f_airT_c, gpp_f_airT_h) => land.gppAirT
    return land
end

@doc """
temperature stress on gpp_potential based on GSI implementation of LPJ

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_GSI

*Inputs*
 - Rg: shortwave radiation incoming for the current time step
 - fT_c_τ: contribution of current time step

*Outputs*
 - land.gppAirT.gpp_f_airT: light effect on GPP between 0-1

---

# Extended help

*References*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions*
 - 1.1 on 22.01.2021 (skoirala

*Created by:*
 - skoirala

*Notes*
"""
gppAirT_GSI
