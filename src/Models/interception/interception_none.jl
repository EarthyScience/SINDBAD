export interception_none

struct interception_none <: interception
end

function precompute(o::interception_none, forcing, land, helpers)

	## calculate variables
	interception = helpers.numbers.𝟘

	## pack land variables
	@pack_land interception => land.fluxes
	return land
end

@doc """
sets the interception evaporation to zero

# precompute:
precompute/instantiate time-invariant variables for interception_none


---

# Extended help
"""
interception_none