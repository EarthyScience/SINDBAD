export transpirationDemand_CASA, transpirationDemand_CASA_h
"""
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationDemand_CASA{T} <: transpirationDemand
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::transpirationDemand_CASA, forcing, land, infotem)
	# @unpack_transpirationDemand_CASA o
	return land
end

function compute(o::transpirationDemand_CASA, forcing, land, infotem)
	@unpack_transpirationDemand_CASA o

	## unpack variables
	@unpack_land begin
		pawAct ∈ land.states
		(p_wAWC, p_α, p_β) ∈ land.soilWBase
		soilWPerc ∈ land.fluxes
		PET ∈ land.PET
	end
	VMC = min(max(sum(pawAct), 0.0) / sum(p_wAWC), 1)
	RDR = (1 + mean(p_α, 2)) / (1 + mean(p_α, 2) * (VMC ^ mean(p_β, 2)))
	tranDem = soilWPerc + (PET - soilWPerc) * RDR

	## pack variables
	@pack_land begin
		tranDem ∋ land.transpirationDemand
	end
	return land
end

function update(o::transpirationDemand_CASA, forcing, land, infotem)
	# @unpack_transpirationDemand_CASA o
	return land
end

"""
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

# precompute:
precompute/instantiate time-invariant variables for transpirationDemand_CASA

# compute:
Demand-driven transpiration using transpirationDemand_CASA

*Inputs:*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_[α/β]: moisture retention characteristics
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water

*Outputs:*
 - land.transpirationSupply.tranSup: supply limited transpiration

# update
update pools and states in transpirationDemand_CASA
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: split the original tranSup of CASA into demand  supply: actual [minimum] is now just demSup approach of transpiration  

*Created by:*
 - Nuno Carvalhais [ncarval]
 - Sujan Koirala [skoirala]

*Notes:*
 - The supply limit has non-linear relationship with moisture state over the root zone
"""
function transpirationDemand_CASA_h end