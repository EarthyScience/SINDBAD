export evaporation_none

struct evaporation_none <: evaporation
end

function instantiate(o::evaporation_none, forcing, land, helpers)

	## calculate variables
	evaporation = helpers.numbers.𝟘

	## pack land variables
	@pack_land evaporation => land.fluxes
	return land
end

@doc """
sets the soil evaporation to zero

# instantiate:
instantiate/instantiate time-invariant variables for evaporation_none


---

# Extended help
"""
evaporation_none