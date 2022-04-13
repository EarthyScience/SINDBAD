export transpirationSupply_Federer1982, transpirationSupply_Federer1982_h
"""
calculate the supply limited transpiration as a function of max rate parameter & avaialable water

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationSupply_Federer1982{T1} <: transpirationSupply
	maxRate::T1 = 5.0 | (0.1, 20.0) | "Maximum rate of transpiration in mm/day" | "mm/day"
end

function precompute(o::transpirationSupply_Federer1982, forcing, land, infotem)
	# @unpack_transpirationSupply_Federer1982 o
	return land
end

function compute(o::transpirationSupply_Federer1982, forcing, land, infotem)
	@unpack_transpirationSupply_Federer1982 o

	## unpack variables
	@unpack_land begin
		pawAct ∈ land.states
		p_wSat ∈ land.soilWBase
	end
	tranSup = maxRate * sum(pawAct) / sum(p_wSat)

	## pack variables
	@pack_land begin
		tranSup ∋ land.transpirationSupply
	end
	return land
end

function update(o::transpirationSupply_Federer1982, forcing, land, infotem)
	# @unpack_transpirationSupply_Federer1982 o
	return land
end

"""
calculate the supply limited transpiration as a function of max rate parameter & avaialable water

# precompute:
precompute/instantiate time-invariant variables for transpirationSupply_Federer1982

# compute:
Supply-limited transpiration using transpirationSupply_Federer1982

*Inputs:*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water

*Outputs:*
 - land.transpirationSupply.tranSup: demand driven transpiration

# update
update pools and states in transpirationSupply_Federer1982
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function transpirationSupply_Federer1982_h end