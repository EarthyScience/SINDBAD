export gpp_coupled

struct gpp_coupled <: gpp end

function compute(params::gpp_coupled, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        transpiration_supply ∈ land.states
        gpp_f_soilW ∈ land.gppSoilW
        gpp_demand ∈ land.gppDemand
        WUE ∈ land.WUE
    end

    gpp = min(transpiration_supply * WUE, gpp_demand * gpp_f_soilW)

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
 - land.WUE.WUE: water use efficiency in gC/mmH2O
 - land.gppDemand.gpp_demand: Demand-driven GPP with stressors except soilW applied
 - land.gppSoilW.gpp_f_soilW: soil moisture stress on photosynthetic capacity
 - land.states.transpiration_supply: supply limited transpiration

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
