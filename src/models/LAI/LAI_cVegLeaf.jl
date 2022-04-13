export LAI_cVegLeaf, LAI_cVegLeaf_h
"""
sets the value of land.states.LAI from the carbon in the leaves of the previous time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct LAI_cVegLeaf{T1} <: LAI
	SLA::T1 = 0.016 | (0.01, 0.024) | "specific leaf area" | "m^2.gC^-1"
end

function precompute(o::LAI_cVegLeaf, forcing, land, infotem)
	# @unpack_LAI_cVegLeaf o
	return land
end

function compute(o::LAI_cVegLeaf, forcing, land, infotem)
	@unpack_LAI_cVegLeaf o

	## unpack variables
	@unpack_land begin
		cEco ∈ land.pools
	end
	cVegLeafZix = infotem.pools.carbon.zix.cVegLeaf
	cVegLeaf = cEco[cVegLeafZix]
	LAI = cVegLeaf* SLA; #

	## pack variables
	@pack_land begin
		LAI ∋ land.states
	end
	return land
end

function update(o::LAI_cVegLeaf, forcing, land, infotem)
	# @unpack_LAI_cVegLeaf o
	return land
end

"""
sets the value of land.states.LAI from the carbon in the leaves of the previous time step

# precompute:
precompute/instantiate time-invariant variables for LAI_cVegLeaf

# compute:
Leaf area index using LAI_cVegLeaf

*Inputs:*
 - land.pools.cEco[cVegLeafZix]: carbon in the leave

*Outputs:*
 - land.states.LAI: the value of LAI for current time step

# update
update pools and states in LAI_cVegLeaf
 - land.states.LAI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 05.05.2020 [sbesnard]

*Created by:*
 - Simon Besnard [sbesnard]
"""
function LAI_cVegLeaf_h end