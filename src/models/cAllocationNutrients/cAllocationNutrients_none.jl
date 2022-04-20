export cAllocationNutrients_none

struct cAllocationNutrients_none <: cAllocationNutrients
end

function precompute(o::cAllocationNutrients_none, forcing, land, helpers)

	## calculate variables
	minWLNL = helpers.numbers.one

	## pack land variables
	@pack_land minWLNL => land.cAllocationNutrients
	return land
end

@doc """
set the pseudo-nutrient limitation to 1

# precompute:
precompute/instantiate time-invariant variables for cAllocationNutrients_none


---

# Extended help
"""
cAllocationNutrients_none