export transpirationDemand_PETfAPAR

@bounds @describe @units @with_kw struct transpirationDemand_PETfAPAR{T1} <: transpirationDemand
	αVeg::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end

function compute(o::transpirationDemand_PETfAPAR, forcing, land, infotem)
	## unpack parameters
	@unpack_transpirationDemand_PETfAPAR o

	## unpack land variables
	@unpack_land begin
		fAPAR ∈ land.states
		PET ∈ land.PET
	end
	tranDem = PET * αVeg * fAPAR

	## pack land variables
	@pack_land tranDem => land.transpirationDemand
	return land
end

@doc """
calculate the climate driven demand for transpiration as a function of PET & fAPAR

# Parameters
$(PARAMFIELDS)

---

# compute:
Demand-driven transpiration using transpirationDemand_PETfAPAR

*Inputs*
 - land.PET.PET : potential evapotranspiration out of PET module
 - land.states.fAPAR: fAPAR
 - αVeg: α parameter for potential transpiration

*Outputs*
 - land.transpirationDemand.tranDem: demand driven transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 30.04.2020 [skoirala]:  

*Created by:*
 - sbesnard; skoirala; ncarval

*Notes*
 - Assumes that the transpiration demand scales with vegetated fraction
"""
transpirationDemand_PETfAPAR