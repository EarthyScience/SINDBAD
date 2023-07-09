export gpp_coupled

struct gpp_coupled <: gpp end

function define(p_struct::gpp_coupled, forcing, land, helpers)
    gpp = helpers.numbers.𝟘
    @pack_land gpp => land.fluxes
    return land
end

function compute(p_struct::gpp_coupled, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        transpiration_supply ∈ land.transpirationSupply
        gpp_f_soilW ∈ land.gppSoilW
        gpp_demand ∈ land.gppDemand
        AoE ∈ land.WUE
        𝟙 ∈ helpers.numbers
    end

    gpp = min(transpiration_supply * AoE, gpp_demand * gpp_f_soilW)

    ## pack land variables
    @pack_land gpp => land.fluxes
    return land
end

@doc """
calculate GPP based on transpiration supply & water use efficiency [coupled]

---

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_coupled

*Inputs*
 - land.WUE.AoE: water use efficiency in gC/mmH2O
 - land.gppDemand.gpp_demand: Demand-driven GPP with stressors except soilW applied
 - land.gppSoilW.gpp_f_soilW: soil moisture stress on photosynthetic capacity
 - land.transpirationSupply.transpiration_supply: supply limited transpiration

*Outputs*
 - land.fluxes.gpp: actual GPP [gC/m2/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - mjung
 - skoirala

*Notes*
"""
gpp_coupled
