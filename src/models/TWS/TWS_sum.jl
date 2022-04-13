export TWS_sum, TWS_sum_h
"""
calculates total water storage as a sum of all potential components

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct TWS_sum{T} <: TWS
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::TWS_sum, forcing, land, infotem)
	# @unpack_TWS_sum o
	return land
end

function compute(o::TWS_sum, forcing, land, infotem)
	@unpack_TWS_sum o

	## unpack variables
	@unpack_land begin
		(groundW, snowW, soilW, surfaceW) ∈ land.pools
	end
	soilW_total = sum(soilW)
	TWS = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)

	## pack variables
	@pack_land begin
		(TWS, soilW_total) ∋ land.TWS
	end
	return land
end

function update(o::TWS_sum, forcing, land, infotem)
	# @unpack_TWS_sum o
	return land
end

"""
calculates total water storage as a sum of all potential components

# precompute:
precompute/instantiate time-invariant variables for TWS_sum

# compute:
Calculate the total water storage as a sum of components using TWS_sum

*Inputs:*
 - land.pools.groundW[1]
 - land.pools.snowW[1]
 - land.pools.soilW
 - land.pools.surfaceW[1]

*Outputs:*
 - land.pools.soilW_total: total soil moisture
 - land.pools.wTotal: total water storage

# update
update pools and states in TWS_sum
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 01.04.2022  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function TWS_sum_h end