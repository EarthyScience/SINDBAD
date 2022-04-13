export transpirationSupply_CASA, transpirationSupply_CASA_h
"""
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationSupply_CASA{T} <: transpirationSupply
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::transpirationSupply_CASA, forcing, land, infotem)
	# @unpack_transpirationSupply_CASA o
	return land
end

function compute(o::transpirationSupply_CASA, forcing, land, infotem)
	@unpack_transpirationSupply_CASA o

	## unpack variables
	@unpack_land begin
		pawAct ∈ land.states
	end
	tranSup = sum(pawAct)

	## pack variables
	@pack_land begin
		tranSup ∋ land.transpirationSupply
	end
	return land
end

function update(o::transpirationSupply_CASA, forcing, land, infotem)
	# @unpack_transpirationSupply_CASA o
	return land
end

"""
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

# precompute:
precompute/instantiate time-invariant variables for transpirationSupply_CASA

# compute:
Supply-limited transpiration using transpirationSupply_CASA

*Inputs:*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_[α/β]: moisture retention characteristics
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water

*Outputs:*
 - land.transpirationSupply.tranSup: supply limited transpiration

# update
update pools and states in transpirationSupply_CASA
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
function transpirationSupply_CASA_h end