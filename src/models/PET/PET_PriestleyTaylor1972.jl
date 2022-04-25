export PET_PriestleyTaylor1972

struct PET_PriestleyTaylor1972 <: PET
end

function compute(o::PET_PriestleyTaylor1972, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing (Rn, Tair) ∈ forcing
    @unpack_land 𝟘  ∈ helpers.numbers


    ## calculate variables
    Δ = 6.11 * exp(17.26938818 * Tair / (237.3 + Tair))
    Lhv = (5.147 * exp(-0.0004643 * Tair) - 2.6466) # MJ kg-1
    γ = 0.4 / 0.622 # hPa C-1 [psychometric constant]
    PET = 1.26 * Δ / (Δ + γ) * Rn / Lhv
    PET = max(PET, 𝟘)

    ## pack land variables
    @pack_land PET => land.PET
    return land
end

@doc """
Calculates the value of land.PET.PET from the forcing variables

---

# compute:
Set potential evapotranspiration using PET_PriestleyTaylor1972

*Inputs*
 - forcing.Rn: Net radiation
 - forcing.Tair: Air temperature

*Outputs*
 - land.PET.PET: the value of PET for current time step

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