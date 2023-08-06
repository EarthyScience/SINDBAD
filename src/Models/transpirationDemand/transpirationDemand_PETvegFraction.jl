export transpirationDemand_PETvegFraction

#! format: off
@bounds @describe @units @with_kw struct transpirationDemand_PETvegFraction{T1} <: transpirationDemand
    α::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end
#! format: on

function compute(p_struct::transpirationDemand_PETvegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationDemand_PETvegFraction p_struct

    ## unpack land variables
    @unpack_land begin
        frac_vegetation ∈ land.states
        PET ∈ land.fluxes
    end
    transpiration_demand = PET * α * frac_vegetation

    ## pack land variables
    @pack_land transpiration_demand => land.transpirationDemand
    return land
end

@doc """
calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction

# Parameters
$(SindbadParameters)

---

# compute:
Demand-driven transpiration using transpirationDemand_PETvegFraction

*Inputs*
 - land.fluxes.PET : potential evapotranspiration out of PET module
 - land.states.frac_vegetation: vegetation fraction
 - α: α parameter for potential transpiration

*Outputs*
 - land.transpirationDemand.transpiration_demand: demand driven transpiration

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - skoirala

*Notes*
 - Assumes that the transpiration demand scales with vegetated fraction
"""
transpirationDemand_PETvegFraction
