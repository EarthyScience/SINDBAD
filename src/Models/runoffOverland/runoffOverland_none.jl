export runoffOverland_none

struct runoffOverland_none <: runoffOverland
end

function instantiate(o::runoffOverland_none, forcing, land, helpers)

	## calculate variables
	runoffOverland = helpers.numbers.𝟘

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
sets overland runoff to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffOverland_none


---

# Extended help
"""
runoffOverland_none