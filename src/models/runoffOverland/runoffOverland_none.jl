export runoffOverland_none

struct runoffOverland_none <: runoffOverland
end

function precompute(o::runoffOverland_none, forcing, land, helpers)

	## calculate variables
	runoffOverland = helpers.numbers.zero

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
sets overland runoff to zero

# precompute:
precompute/instantiate time-invariant variables for runoffOverland_none


---

# Extended help
"""
runoffOverland_none