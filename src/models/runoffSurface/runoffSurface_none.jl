export runoffSurface_none

struct runoffSurface_none <: runoffSurface
end

function precompute(o::runoffSurface_none, forcing, land, helpers)

	## calculate variables
	runoffSurface = helpers.numbers.𝟘

	## pack land variables
	@pack_land runoffSurface => land.fluxes
	return land
end

@doc """
sets surface runoff [runoffSurface] from the storage to zero

# precompute:
precompute/instantiate time-invariant variables for runoffSurface_none


---

# Extended help
"""
runoffSurface_none