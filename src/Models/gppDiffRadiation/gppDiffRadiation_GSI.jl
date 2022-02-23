export gppDiffRadiation_GSI

@bounds @describe @units @with_kw struct gppDiffRadiation_GSI{T1,T2,T3} <: gppDiffRadiation
    fR_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
    fR_slope::T2 = 58.0 | (1.0, 100.0) | "slope of sigmoid" | "fraction"
    fR_base::T3 = 59.78 | (1.0, 120.0) | "base of sigmoid" | "fraction"
end


function precompute(o::gppDiffRadiation_GSI, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_GSI o
    @unpack_forcing Rg ∈ forcing
    @unpack_land (𝟙, 𝟘) ∈ helpers.numbers


    f_smooth = (f_p, f_n, τ, slope, base) -> (𝟙 - τ) * f_p + τ * (𝟙 / (𝟙 + exp(-slope * (f_n - base))))
    CloudScGPP_prev = 𝟘


    ## pack land variables
    @pack_land (CloudScGPP_prev, f_smooth) => land.gppDiffRadiation
    return land
end

function compute(o::gppDiffRadiation_GSI, forcing, land::NamedTuple, helpers::NamedTuple)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_GSI o
    @unpack_forcing Rg ∈ forcing


    ## unpack land variables
    @unpack_land begin
        (CloudScGPP_prev, f_smooth) ∈ land.gppDiffRadiation
        (𝟘, 𝟙) ∈ helpers.numbers
    end


    ## calculate variables
    f_prev = CloudScGPP_prev
    Rg = Rg * 11.57407 # multiplied by a scalar to covert MJ/m2/day to W/m2
    fR = f_smooth(f_prev, Rg, fR_τ, fR_slope, fR_base)
    CloudScGPP = clamp(fR, 𝟘, 𝟙)
    CloudScGPP_prev = CloudScGPP

    ## pack land variables
    @pack_land (CloudScGPP, CloudScGPP_prev) => land.gppDiffRadiation
    return land
end

@doc """
cloudiness scalar [radiation diffusion] on gppPot based on GSI implementation of LPJ

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - Rg: shortwave radiation incoming
 - fR_τ: contribution of current time step

*Outputs*
 - land.gppDiffRadiation.CloudScGPP: light effect on GPP between 0-1

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