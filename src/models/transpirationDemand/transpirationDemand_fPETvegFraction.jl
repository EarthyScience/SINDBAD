export transpirationDemand_fPETvegFraction, transpirationDemand_fPETvegFraction_h
"""
calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationDemand_fPETvegFraction{T1} <: transpirationDemand
	αVeg::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end

function precompute(o::transpirationDemand_fPETvegFraction, forcing, land, infotem)
	# @unpack_transpirationDemand_fPETvegFraction o
	return land
end

function compute(o::transpirationDemand_fPETvegFraction, forcing, land, infotem)
	@unpack_transpirationDemand_fPETvegFraction o

	## unpack variables
	@unpack_land begin
		vegFraction ∈ land.states
		PET ∈ land.PET
	end
	tranDem = PET * αVeg * vegFraction

	## pack variables
	@pack_land begin
		tranDem ∋ land.transpirationDemand
	end
	return land
end

function update(o::transpirationDemand_fPETvegFraction, forcing, land, infotem)
	# @unpack_transpirationDemand_fPETvegFraction o
	return land
end

"""
calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction

# precompute:
precompute/instantiate time-invariant variables for transpirationDemand_fPETvegFraction

# compute:
Demand-driven transpiration using transpirationDemand_fPETvegFraction

*Inputs:*
 - land.PET.PET : potential evapotranspiration out of PET module
 - land.states.vegFraction: vegetation fraction
 - αVeg: α parameter for potential transpiration

*Outputs:*
 - land.transpirationDemand.tranDem: demand driven transpiration

# update
update pools and states in transpirationDemand_fPETvegFraction
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - Assumes that the transpiration demand scales with vegetated fraction
"""
function transpirationDemand_fPETvegFraction_h end