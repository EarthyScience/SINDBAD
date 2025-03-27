export runoffInfiltrationExcess_kUnsat

struct runoffInfiltrationExcess_kUnsat <: runoffInfiltrationExcess end

function compute(params::runoffInfiltrationExcess_kUnsat, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        WBP ⇐ land.states
        unsat_k_model ⇐ land.models
        (z_zero, o_one) ⇐ land.constants
    end
    # get the unsaturated hydraulic conductivity based on soil properties for the first soil layer
    k_unsat = unsatK(land, helpers, 1, unsat_k_model)
    # minimum of the conductivity & the incoming water
    inf_excess_runoff = maxZero(WBP - k_unsat)
    # update remaining water
    WBP = WBP - inf_excess_runoff

    ## pack land variables
    @pack_nt begin
        inf_excess_runoff ⇒ land.fluxes
        WBP ⇒ land.states
    end
    return land
end

@doc """
infiltration excess runoff based on unsτrated hydraulic conductivity

---

# compute:
Infiltration excess runoff using runoffInfiltrationExcess_kUnsat

*Inputs*
 - land.p.soilProperties.unsatK: function to calculate unsaturated K: out of pSoil [Saxtion1986 | Saxton2006] end
 - land.pools.soilW of first layer

*Outputs*
 - land.fluxes.PETSoil
 - land.fluxes.evaporation
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*

*Versions*
 - 1.0 on 23.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
runoffInfiltrationExcess_kUnsat
