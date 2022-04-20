export cAllocationLAI_none

struct cAllocationLAI_none <: cAllocationLAI
end

function precompute(o::cAllocationLAI_none, forcing, land, helpers)

	## calculate variables
	LL = helpers.numbers.one

	## pack land variables
	@pack_land LL => land.cAllocationLAI
	return land
end

@doc """
set the allocation to ones

# precompute:
precompute/instantiate time-invariant variables for cAllocationLAI_none


---

# Extended help
"""
cAllocationLAI_none