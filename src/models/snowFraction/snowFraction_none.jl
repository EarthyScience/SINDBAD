export snowFraction_none

struct snowFraction_none <: snowFraction
end

function precompute(o::snowFraction_none, forcing, land, infotem)

	## calculate variables
	snowFraction = infotem.helpers.zero

	## pack land variables
	@pack_land snowFraction => land.states
	return land
end

@doc """
sets the snow fraction to zeros

# precompute:
precompute/instantiate time-invariant variables for snowFraction_none


---

# Extended help
"""
snowFraction_none