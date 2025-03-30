export gppDiffRadiation_GSI

#! format: off
@bounds @describe @units @timescale @with_kw struct gppDiffRadiation_GSI{T1,T2,T3} <: gppDiffRadiation
    fR_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction" | ""
    fR_slope::T2 = 58.0 | (1.0, 100.0) | "slope of sigmoid" | "fraction" | ""
    fR_base::T3 = 59.78 | (1.0, 120.0) | "base of sigmoid" | "fraction" | ""
end
#! format: on

function define(params::gppDiffRadiation_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_GSI params
    @unpack_nt f_rg ⇐ forcing
    @unpack_nt o_one ⇐ land.constants

    gpp_f_cloud_prev = o_one
    gpp_f_cloud = o_one
    MJ_to_W = oftype(fR_base, 11.57407)

    ## pack land variables
    @pack_nt (gpp_f_cloud, gpp_f_cloud_prev, MJ_to_W) ⇒ land.diagnostics
    return land
end

function compute(params::gppDiffRadiation_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_GSI params
    @unpack_nt f_rg ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        (gpp_f_cloud_prev, MJ_to_W) ⇐ land.diagnostics
        (z_zero, o_one) ⇐ land.constants
    end
    ## calculate variables
    f_prev = gpp_f_cloud_prev
    f_rg = f_rg * MJ_to_W # multiplied by a scalar to covert MJ/m2/day to W/m2
    fR = (o_one - fR_τ) * f_prev + fR_τ * (o_one / (o_one + exp(-fR_slope * (f_rg - fR_base))))
    gpp_f_cloud = clampZeroOne(fR)
    gpp_f_cloud_prev = gpp_f_cloud

    ## pack land variables
    @pack_nt (gpp_f_cloud, gpp_f_cloud_prev) ⇒ land.diagnostics
    return land
end

purpose(::Type{gppDiffRadiation_GSI}) = "cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ"

@doc """

$(getBaseDocString(gppDiffRadiation_GSI))

---

# Extended help

*References*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions*
 - 1.1 on 22.01.2021 (skoirala

*Created by*
 - skoirala

*Notes*
"""
gppDiffRadiation_GSI
