export transpirationDemand_PET, transpirationDemand_PET_h
"""
set the climate driven demand for transpiration equal to PET

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationDemand_PET{T} <: transpirationDemand
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::transpirationDemand_PET, forcing, land, infotem)
	# @unpack_transpirationDemand_PET o
	return land
end

function compute(o::transpirationDemand_PET, forcing, land, infotem)
	@unpack_transpirationDemand_PET o

	## unpack variables
	@unpack_land begin
		PET ∈ land.PET
	end
	tranDem = PET

	## pack variables
	@pack_land begin
		tranDem ∋ land.transpirationDemand
	end
	return land
end

function update(o::transpirationDemand_PET, forcing, land, infotem)
	# @unpack_transpirationDemand_PET o
	return land
end

"""
set the climate driven demand for transpiration equal to PET

# precompute:
precompute/instantiate time-invariant variables for transpirationDemand_PET

# compute:
Demand-driven transpiration using transpirationDemand_PET

*Inputs:*
 - land.PET.PET : potential evapotranspiration out of PET module

*Outputs:*
 - land.transpirationDemand.tranDem: demand driven transpiration

# update
update pools and states in transpirationDemand_PET
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - Assumes potential transpiration to be equal to PET
"""
function transpirationDemand_PET_h end