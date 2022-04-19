export runoffBase_none

struct runoffBase_none <: runoffBase
end

function precompute(o::runoffBase_none, forcing, land, infotem)

	## calculate variables
	runoffBase = infotem.helpers.zero

	## pack land variables
	@pack_land runoffBase => land.fluxes
	return land
end

@doc """
sets the base runoff to zeros

# precompute:
precompute/instantiate time-invariant variables for runoffBase_none


---

# Extended help
"""
runoffBase_none