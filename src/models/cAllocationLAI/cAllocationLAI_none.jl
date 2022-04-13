export cAllocationLAI_none, cAllocationLAI_none_h
"""
set the allocation to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationLAI_none{T} <: cAllocationLAI
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationLAI_none, forcing, land, infotem)
	@unpack_cAllocationLAI_none o

	## calculate variables
	LL = 1.0

	## pack variables
	@pack_land begin
		LL ∋ land.cAllocationLAI
	end
	return land
end

function compute(o::cAllocationLAI_none, forcing, land, infotem)
	# @unpack_cAllocationLAI_none o
	return land
end

function update(o::cAllocationLAI_none, forcing, land, infotem)
	# @unpack_cAllocationLAI_none o
	return land
end

"""
set the allocation to ones

# Extended help
"""
function cAllocationLAI_none_h end