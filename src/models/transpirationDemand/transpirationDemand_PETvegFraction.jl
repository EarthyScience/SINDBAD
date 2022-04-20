export transpirationDemand_PETvegFraction

@bounds @describe @units @with_kw struct transpirationDemand_PETvegFraction{T1} <: transpirationDemand
	αVeg::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end

function compute(o::transpirationDemand_PETvegFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_transpirationDemand_PETvegFraction o

	## unpack land variables
	@unpack_land begin
		vegFraction ∈ land.states
		PET ∈ land.PET
	end
	tranDem = PET * αVeg * vegFraction

	## pack land variables
	@pack_land tranDem => land.transpirationDemand
	return land
end

@doc """
calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction

# Parameters
$(PARAMFIELDS)

---

# compute:
Demand-driven transpiration using transpirationDemand_PETvegFraction

*Inputs*
 - land.PET.PET : potential evapotranspiration out of PET module
 - land.states.vegFraction: vegetation fraction
 - αVeg: α parameter for potential transpiration

*Outputs*
 - land.transpirationDemand.tranDem: demand driven transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - skoirala

*Notes*
 - Assumes that the transpiration demand scales with vegetated fraction
"""
transpirationDemand_PETvegFraction