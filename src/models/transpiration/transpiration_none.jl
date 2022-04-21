export transpiration_none

struct transpiration_none <: transpiration
end

function precompute(o::transpiration_none, forcing, land, helpers)

	## calculate variables
	transpiration = helpers.numbers.zero

	## pack land variables
	@pack_land transpiration => land.fluxes
	return land
end

@doc """
sets the actual transpiration to zero

# precompute:
precompute/instantiate time-invariant variables for transpiration_none


---

# Extended help
"""
transpiration_none