export runoffInterflow_none

struct runoffInterflow_none <: runoffInterflow
end

function precompute(o::runoffInterflow_none, forcing, land, infotem)

	## calculate variables
	runoffInterflow = infotem.helpers.zero

	## pack land variables
	@pack_land runoffInterflow => land.fluxes
	return land
end

@doc """
sets interflow runoff to zeros

# precompute:
precompute/instantiate time-invariant variables for runoffInterflow_none


---

# Extended help
"""
runoffInterflow_none