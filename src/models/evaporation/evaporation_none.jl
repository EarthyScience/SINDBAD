export evaporation_none

struct evaporation_none <: evaporation
end

function precompute(o::evaporation_none, forcing, land, infotem)

	## calculate variables
	evaporation = infotem.helpers.zero

	## pack land variables
	@pack_land evaporation => land.fluxes
	return land
end

@doc """
sets the soil evaporation to zeros

# precompute:
precompute/instantiate time-invariant variables for evaporation_none


---

# Extended help
"""
evaporation_none