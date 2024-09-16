export gppAirT_GSI

#! format: off
@bounds @describe @units @with_kw struct gppAirT_GSI{T1,T2,T3,T4,T5,T6} <: gppAirT
    f_airT_c_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor for cold stress" | "fraction"
    f_airT_c_slope::T2 = 0.25 | (0.0, 100.0) | "slope of sigmoid for cold stress" | "fraction"
    f_airT_c_base::T3 = 7.0 | (1.0, 15.0) | "base of sigmoid for cold stress" | "fraction"
    f_airT_h_τ::T4 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor for heat stress" | "fraction"
    f_airT_h_slope::T5 = 1.74 | (0.0, 100.0) | "slope of sigmoid for heat stress" | "fraction"
    f_airT_h_base::T6 = 41.51 | (25.0, 65.0) | "base of sigmoid for heat stress" | "fraction"
end
#! format: on

function define(params::gppAirT_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppAirT_GSI params
    @unpack_nt o_one ⇐ land.constants

    gpp_f_airT_c = o_one
    gpp_f_airT_h = o_one
    f_smooth =
        (f_p, f_n, τ, slope, base) -> (o_one - τ) * f_p +
                                      τ * (o_one / (o_one + exp(-slope * (f_n - base))))

    ## pack land variables
    @pack_nt (gpp_f_airT_c, gpp_f_airT_h, f_smooth) ⇒ land.diagnostics
    return land
end

function compute(params::gppAirT_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_GSI params
    @unpack_nt f_airT ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        (gpp_f_airT_c, gpp_f_airT_h, f_smooth) ⇐ land.diagnostics
        (z_zero, o_one) ⇐ land.constants
    end

    ## calculate variables
    f_c_prev = gpp_f_airT_c
    f_airT_c = f_smooth(f_c_prev, f_airT, f_airT_c_τ, f_airT_c_slope, f_airT_c_base)
    cScGPP = clampZeroOne(f_airT_c)

    f_h_prev = gpp_f_airT_h
    f_airT_h = f_smooth(f_h_prev, f_airT, f_airT_h_τ, -f_airT_h_slope, f_airT_h_base)
    hScGPP = clampZeroOne(f_airT_h)

    gpp_f_airT = min(cScGPP, hScGPP)

    gpp_f_airT_c = cScGPP
    gpp_f_airT_h = hScGPP

    ## pack land variables
    @pack_nt (gpp_f_airT, cScGPP, hScGPP, gpp_f_airT_c, gpp_f_airT_h) ⇒ land.diagnostics
    return land
end

@doc """
temperature stress on gpp_potential based on GSI implementation of LPJ

# Parameters
$(SindbadParameters)

---

# compute:
Effect of temperature using gppAirT_GSI

*Inputs*
 - f_rg: shortwave radiation incoming for the current time step
 - f_airT_c_τ: contribution of current time step

*Outputs*
 - land.diagnostics.gpp_f_airT: light effect on GPP between 0-1

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
