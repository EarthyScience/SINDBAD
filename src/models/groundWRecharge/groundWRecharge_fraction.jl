export groundWRecharge_fraction, groundWRecharge_fraction_h
"""
calculates GW recharge as a fraction of soil moisture of the lowermost layer

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct groundWRecharge_fraction{T1} <: groundWRecharge
	rf::T1 = 0.1 | (0.01, 1.0) | "fraction of land runoff that percolates to groundwater" | ""
end

function precompute(o::groundWRecharge_fraction, forcing, land, infotem)
	# @unpack_groundWRecharge_fraction o
	return land
end

function compute(o::groundWRecharge_fraction, forcing, land, infotem)
	@unpack_groundWRecharge_fraction o

	## unpack variables
	@unpack_land begin
		(groundW, soilW) ∈ land.pools
	end
	# calculate recharge
	gwRec = rf * soilW[infotem.pools.water.nZix.soilW]

	## pack variables
	@pack_land begin
		gwRec ∋ land.fluxes
	end
	return land
end

function update(o::groundWRecharge_fraction, forcing, land, infotem)
	@unpack_groundWRecharge_fraction o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
		gwRec ∈ land.fluxes
	end

	## update variables
	# update storages pool
	soilW[infotem.pools.water.nZix.soilW] = soilW[infotem.pools.water.nZix.soilW] - gwRec
	groundW[1] = groundW[1] + gwRec

	## pack variables
	@pack_land begin
		(groundW, soilW) ∋ land.pools
	end
	return land
end

"""
calculates GW recharge as a fraction of soil moisture of the lowermost layer

# precompute:
precompute/instantiate time-invariant variables for groundWRecharge_fraction

# compute:
Recharge the groundwater using groundWRecharge_fraction

*Inputs:*
 - land.pools.soilW

*Outputs:*
 - land.fluxes.gwRec

# update
update pools and states in groundWRecharge_fraction
 - land.pools.groundW[1]

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function groundWRecharge_fraction_h end