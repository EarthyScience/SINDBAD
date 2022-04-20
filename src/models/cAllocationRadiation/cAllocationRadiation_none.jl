export cAllocationRadiation_none

struct cAllocationRadiation_none <: cAllocationRadiation
end

function precompute(o::cAllocationRadiation_none, forcing, land, helpers)

	## calculate variables
	fR = helpers.numbers.one

	## pack land variables
	@pack_land fR => land.cAllocationRadiation
	return land
end

@doc """


# precompute:
precompute/instantiate time-invariant variables for cAllocationRadiation_none


---

# Extended help
"""
cAllocationRadiation_none