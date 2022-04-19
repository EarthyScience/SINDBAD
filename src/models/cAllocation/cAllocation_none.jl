export cAllocation_none

struct cAllocation_none <: cAllocation
end

function precompute(o::cAllocation_none, forcing, land, infotem)

	## calculate variables
	cAlloc = repeat(infotem.helpers.azero, infotem.pools.carbon.nZix.cEco)

	## pack land variables
	@pack_land cAlloc => land.states
	return land
end

@doc """
set the allocation to zeros

# precompute:
precompute/instantiate time-invariant variables for cAllocation_none


---

# Extended help
"""
cAllocation_none