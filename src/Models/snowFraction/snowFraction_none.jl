export snowFraction_none

struct snowFraction_none <: snowFraction
end

function instantiate(o::snowFraction_none, forcing, land, helpers)

	## calculate variables
	snowFraction = helpers.numbers.𝟘

	## pack land variables
	@pack_land snowFraction => land.states
	return land
end

@doc """
sets the snow fraction to zero

# instantiate:
instantiate/instantiate time-invariant variables for snowFraction_none


---

# Extended help
"""
snowFraction_none