export transpirationSupply_wAWC, transpirationSupply_wAWC_h
"""
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationSupply_wAWC{T1} <: transpirationSupply
	tranFrac::T1 = 1.0 | (0.02, 1.0) | "fraction of total maximum available water that can be transpired" | ""
end

function precompute(o::transpirationSupply_wAWC, forcing, land, infotem)
	# @unpack_transpirationSupply_wAWC o
	return land
end

function compute(o::transpirationSupply_wAWC, forcing, land, infotem)
	@unpack_transpirationSupply_wAWC o

	## unpack variables
	@unpack_land begin
		pawAct ∈ land.states
	end
	tranSup = sum(pawAct) * tranFrac

	## pack variables
	@pack_land begin
		tranSup ∋ land.transpirationSupply
	end
	return land
end

function update(o::transpirationSupply_wAWC, forcing, land, infotem)
	# @unpack_transpirationSupply_wAWC o
	return land
end

"""
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture

# precompute:
precompute/instantiate time-invariant variables for transpirationSupply_wAWC

# compute:
Supply-limited transpiration using transpirationSupply_wAWC

*Inputs:*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water

*Outputs:*
 - land.transpirationSupply.tranSup: supply limited transpiration

# update
update pools and states in transpirationSupply_wAWC
 -

# Extended help

*References:*
 - Teuling; 2007 | 2009: Time scales.#

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function transpirationSupply_wAWC_h end