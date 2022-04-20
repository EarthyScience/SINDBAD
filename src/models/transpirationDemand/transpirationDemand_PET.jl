export transpirationDemand_PET

@bounds @describe @units @with_kw struct transpirationDemand_PET{T1} <: transpirationDemand
	αVeg::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end

function compute(o::transpirationDemand_PET, forcing, land, helpers)
	## unpack parameters
	@unpack_transpirationDemand_PET o

	## unpack land variables
	@unpack_land PET ∈ land.PET

	## calculate variables
	tranDem = PET * αVeg

	## pack land variables
	@pack_land tranDem => land.transpirationDemand
	return land
end

@doc """
calculate the climate driven demand for transpiration as a function of PET & α for vegetation

# Parameters
$(PARAMFIELDS)

---

# compute:
Demand-driven transpiration using transpirationDemand_PET

*Inputs*
 - land.PET.PET : potential evapotranspiration out of PET module
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
"""
transpirationDemand_PET