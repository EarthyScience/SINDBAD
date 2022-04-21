export sublimation_none

struct sublimation_none <: sublimation
end

function precompute(o::sublimation_none, forcing, land, helpers)

	## calculate variables
	sublimation = helpers.numbers.zero

	## pack land variables
	@pack_land sublimation => land.fluxes
	return land
end

@doc """
sets the snow sublimation to zero

# precompute:
precompute/instantiate time-invariant variables for sublimation_none


---

# Extended help
"""
sublimation_none