export gppDiffRadiation_GSI

#! format: off
@bounds @describe @units @with_kw struct gppDiffRadiation_GSI{T1,T2,T3} <: gppDiffRadiation
    fR_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
    fR_slope::T2 = 58.0 | (1.0, 100.0) | "slope of sigmoid" | "fraction"
    fR_base::T3 = 59.78 | (1.0, 120.0) | "base of sigmoid" | "fraction"
end
#! format: on

function define(p_struct::gppDiffRadiation_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_GSI p_struct
    @unpack_forcing Rg ∈ forcing
    @unpack_land (𝟙, 𝟘) ∈ helpers.numbers

    gpp_f_cloud_prev = 𝟘
    gpp_f_cloud = 𝟙
    MJ_to_W = helpers.numbers.sNT(11.57407)

    ## pack land variables
    @pack_land (gpp_f_cloud, gpp_f_cloud_prev, MJ_to_W) => land.gppDiffRadiation
    return land
end

function compute(p_struct::gppDiffRadiation_GSI, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_GSI p_struct
    @unpack_forcing Rg ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (gpp_f_cloud_prev, MJ_to_W) ∈ land.gppDiffRadiation
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    ## calculate variables
    f_prev = gpp_f_cloud_prev
    Rg = Rg * MJ_to_W # multiplied by a scalar to covert MJ/m2/day to W/m2
    fR = (𝟙 - fR_τ) * f_prev + fR_τ * (𝟙 / (𝟙 + exp(-fR_slope * (Rg - fR_base))))
    gpp_f_cloud = clamp_01(fR)
    gpp_f_cloud_prev = gpp_f_cloud

    ## pack land variables
    @pack_land (gpp_f_cloud, gpp_f_cloud_prev) => land.gppDiffRadiation
    return land
end

@doc """
cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - Rg: shortwave radiation incoming
 - fR_τ: contribution of current time step

*Outputs*
 - land.gppDiffRadiation.gpp_f_cloud: light effect on GPP between 0-1

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
gppDiffRadiation_GSI
