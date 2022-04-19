export runoffSurface_none

struct runoffSurface_none <: runoffSurface
end

function precompute(o::runoffSurface_none, forcing, land, infotem)

	## calculate variables
	runoffSurface = infotem.helpers.zero

	## pack land variables
	@pack_land runoffSurface => land.fluxes
	return land
end

@doc """
sets surface runoff [runoffSurface] from the storage to zeros

# precompute:
precompute/instantiate time-invariant variables for runoffSurface_none


---

# Extended help
"""
runoffSurface_none