export runoffOverland_none

struct runoffOverland_none <: runoffOverland
end

function precompute(o::runoffOverland_none, forcing, land, infotem)

	## calculate variables
	runoffOverland = infotem.helpers.zero

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
sets overland runoff to zeros

# precompute:
precompute/instantiate time-invariant variables for runoffOverland_none


---

# Extended help
"""
runoffOverland_none