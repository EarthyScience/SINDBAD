export evaporation_none

struct evaporation_none <: evaporation
end

function precompute(o::evaporation_none, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	evaporation = helpers.numbers.𝟘

	## pack land variables
	@pack_land evaporation => land.fluxes
	return land
end

@doc """
sets the soil evaporation to zero

# precompute:
precompute/instantiate time-invariant variables for evaporation_none


---

# Extended help
"""
evaporation_none