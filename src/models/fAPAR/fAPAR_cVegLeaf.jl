export fAPAR_cVegLeaf, fAPAR_cVegLeaf_h
"""
Compute FAPAR based on carbon pool of the leave; SLA; kLAI

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct fAPAR_cVegLeaf{T1} <: fAPAR
	kEffExt::T1 = 0.005 | (0.0005, 0.05) | "effective light extinction coefficient" | ""
end

function precompute(o::fAPAR_cVegLeaf, forcing, land, infotem)
	# @unpack_fAPAR_cVegLeaf o
	return land
end

function compute(o::fAPAR_cVegLeaf, forcing, land, infotem)
	@unpack_fAPAR_cVegLeaf o

	## unpack variables
	@unpack_land begin
		cEco ∈ land.pools
	end
	cVegLeafZix = infotem.pools.carbon.zix.cVegLeaf
	cVegLeaf = cEco[cVegLeafZix]
	fAPAR = 1-exp(-(cVegLeaf * kEffExt))

	## pack variables
	@pack_land begin
		fAPAR ∋ land.states
	end
	return land
end

function update(o::fAPAR_cVegLeaf, forcing, land, infotem)
	# @unpack_fAPAR_cVegLeaf o
	return land
end

"""
Compute FAPAR based on carbon pool of the leave; SLA; kLAI

# precompute:
precompute/instantiate time-invariant variables for fAPAR_cVegLeaf

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_cVegLeaf

*Inputs:*
 - land.pools.cEco.cVegLeaf

*Outputs:*
 - land.states.fAPAR: the value of fAPAR for current time step

# update
update pools and states in fAPAR_cVegLeaf
 - land.states.fAPAR

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 24.04.2021 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function fAPAR_cVegLeaf_h end