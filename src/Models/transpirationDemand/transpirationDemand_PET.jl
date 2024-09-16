export transpirationDemand_PET

#! format: off
@bounds @describe @units @with_kw struct transpirationDemand_PET{T1} <: transpirationDemand
    α::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end
#! format: on

function compute(params::transpirationDemand_PET, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationDemand_PET params

    ## unpack land variables
    @unpack_nt PET ⇐ land.fluxes

    ## calculate variables
    transpiration_demand = PET * α

    ## pack land variables
    @pack_nt transpiration_demand ⇒ land.diagnostics
    return land
end

@doc """
calculate the climate driven demand for transpiration as a function of PET & α for vegetation

# Parameters
$(SindbadParameters)

---

# compute:
Demand-driven transpiration using transpirationDemand_PET

*Inputs*
 - land.fluxes.PET : potential evapotranspiration out of PET module
 - α: α parameter for potential transpiration

*Outputs*
 - land.diagnostics.transpiration_demand: demand driven transpiration

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
transpirationDemand_PET
