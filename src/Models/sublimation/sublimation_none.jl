export sublimation_none

struct sublimation_none <: sublimation
end

function precompute(o::sublimation_none, forcing, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	sublimation = helpers.numbers.𝟘

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