export PET_PriestleyTaylor1972

#! format: off
@bounds @describe @units @with_kw struct PET_PriestleyTaylor1972{T1,T2,T3,T4,T5,T6,T7,T8,T9} <: PET
    Δ_1::T1 = 6.11 | (-Inf, Inf) | "parameter 1 for calculating Δ" | ""
    Δ_2::T2 = 17.26938818 | (-Inf, Inf) | "parameter 2 for calculating Δ" | ""
    Δ_3::T3 = 237.3 | (-Inf, Inf) | "parameter 3 for calculating Δ" | ""
    Lhv_1::T4 = 5.147 | (-Inf, Inf) | "parameter 1 for calculating Lhv" | ""
    Lhv_2::T5 = -0.0004643 | (-Inf, Inf) | "parameter 2 for calculating Lhv" | ""
    Lhv_3::T6 = 2.6466 | (-Inf, Inf) | "parameter 3 for calculating Lhv" | ""
    γ_1::T7 = 0.4 | (-Inf, Inf) | "parameter 1 for calculating γ" | ""
    γ_2::T8 = 0.622 | (-Inf, Inf) | "parameter 2 for calculating γ" | ""
    PET_1::T9 = 1.26 | (-Inf, Inf) | "parameter 1 for calculating PET" | ""
end
#! format: on

function compute(params::PET_PriestleyTaylor1972, forcing, land, helpers)
    ## unpack parameters
    @unpack_PET_PriestleyTaylor1972 params
    ## unpack forcing
    @unpack_forcing (f_rn, f_airT) ∈ forcing
    @unpack_land z_zero ∈ land.wCycleBase

    ## calculate variables
    Δ = Δ_1 * exp(Δ_2 * f_airT / (Δ_3 + f_airT))
    Lhv = (Lhv_1 * exp(Lhv_2 * f_airT) - Lhv_3) # MJ kg-1
    γ = γ_1 / γ_2 # hPa C-1 [psychometric constant]
    PET = PET_1 * Δ / (Δ + γ) * f_rn / Lhv
    PET = maxZero(PET)

    ## pack land variables
    @pack_land PET => land.fluxes
    return land
end

@doc """
Calculates the value of land.fluxes.PET from the forcing variables

# Parameters
$(SindbadParameters)

---

# compute:
Set potential evapotranspiration using PET_PriestleyTaylor1972

*Inputs*
 - forcing.f_rn: Net radiation
 - forcing.f_airT: Air temperature

*Outputs*
 - land.fluxes.PET: the value of PET for current time step

---

# Extended help

*References*
 - Priestley, C. H. B., & TAYLOR, R. J. (1972). On the assessment of surface heat  flux & evaporation using large-scale parameters.  Monthly weather review, 100[2], 81-92.

*Versions*
 - 1.0 on 20.03.2020 [skoirala]

*Created by:*
 - skoirala
"""
PET_PriestleyTaylor1972
