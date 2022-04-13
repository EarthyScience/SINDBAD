export cAllocation_none, cAllocation_none_h
"""
set the allocation to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocation_none{T} <: cAllocation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocation_none, forcing, land, infotem)
	@unpack_cAllocation_none o

	## calculate variables
	cAlloc = zeros(size(infotem.pools.carbon.initValues.cEco))

	## pack variables
	@pack_land begin
		cAlloc ∋ land.states
	end
	return land
end

function compute(o::cAllocation_none, forcing, land, infotem)
	# @unpack_cAllocation_none o
	return land
end

function update(o::cAllocation_none, forcing, land, infotem)
	# @unpack_cAllocation_none o
	return land
end

"""
set the allocation to zeros

# Extended help
"""
function cAllocation_none_h end