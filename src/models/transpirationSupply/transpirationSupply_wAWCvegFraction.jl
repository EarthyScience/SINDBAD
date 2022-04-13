export transpirationSupply_wAWCvegFraction, transpirationSupply_wAWCvegFraction_h
"""
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpirationSupply_wAWCvegFraction{T1} <: transpirationSupply
	tranFrac::T1 = 1.0 | (0.02, 1.0) | "fraction of total maximum available water that can be transpired" | ""
end

function precompute(o::transpirationSupply_wAWCvegFraction, forcing, land, infotem)
	# @unpack_transpirationSupply_wAWCvegFraction o
	return land
end

function compute(o::transpirationSupply_wAWCvegFraction, forcing, land, infotem)
	@unpack_transpirationSupply_wAWCvegFraction o

	## unpack variables
	@unpack_land begin
		(pawAct, vegFraction) ∈ land.states
	end
	tranSup = sum(pawAct) * tranFrac * vegFraction

	## pack variables
	@pack_land begin
		tranSup ∋ land.transpirationSupply
	end
	return land
end

function update(o::transpirationSupply_wAWCvegFraction, forcing, land, infotem)
	# @unpack_transpirationSupply_wAWCvegFraction o
	return land
end

"""
calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions

# precompute:
precompute/instantiate time-invariant variables for transpirationSupply_wAWCvegFraction

# compute:
Supply-limited transpiration using transpirationSupply_wAWCvegFraction

*Inputs:*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water
 - land.states.vegFraction: vegetation fraction

*Outputs:*
 - land.transpirationSupply.tranSup: supply limited transpiration

# update
update pools and states in transpirationSupply_wAWCvegFraction
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - Assumes that the transpiration supply scales with vegetated fraction
"""
function transpirationSupply_wAWCvegFraction_h end