export transpirationDemand_fPET, transpirationDemand_fPET_h
"""
calculate the climate driven demand for transpiration as a function of PET & α for vegetation

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationDemand_fPET{T1} <: transpirationDemand
	αVeg::T1 = 1.0 | (0.2, 3.0) | "vegetation specific α coefficient of Priestley Taylor PET" | ""
end

function precompute(o::transpirationDemand_fPET, forcing, land, infotem)
	# @unpack_transpirationDemand_fPET o
	return land
end

function compute(o::transpirationDemand_fPET, forcing, land, infotem)
	@unpack_transpirationDemand_fPET o

	## unpack variables
	@unpack_land begin
		PET ∈ land.PET
	end
	tranDem = PET * αVeg

	## pack variables
	@pack_land begin
		tranDem ∋ land.transpirationDemand
	end
	return land
end

function update(o::transpirationDemand_fPET, forcing, land, infotem)
	# @unpack_transpirationDemand_fPET o
	return land
end

"""
calculate the climate driven demand for transpiration as a function of PET & α for vegetation

# precompute:
precompute/instantiate time-invariant variables for transpirationDemand_fPET

# compute:
Demand-driven transpiration using transpirationDemand_fPET

*Inputs:*
 - land.PET.PET : potential evapotranspiration out of PET module
 - αVeg: α parameter for potential transpiration

*Outputs:*
 - land.transpirationDemand.tranDem: demand driven transpiration

# update
update pools and states in transpirationDemand_fPET
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function transpirationDemand_fPET_h end