export cAllocationSoilW_none

struct cAllocationSoilW_none <: cAllocationSoilW
end

function precompute(o::cAllocationSoilW_none, forcing, land, helpers)

	## calculate variables
	fW = helpers.numbers.one

	## pack land variables
	@pack_land fW => land.cAllocationSoilW
	return land
end

@doc """


# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilW_none


---

# Extended help
"""
cAllocationSoilW_none