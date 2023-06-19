export runoffInterflow_none

struct runoffInterflow_none <: runoffInterflow
end

function instantiate(o::runoffInterflow_none, forcing, land, helpers)

	## calculate variables
	runoffInterflow = helpers.numbers.𝟘

	## pack land variables
	@pack_land runoffInterflow => land.fluxes
	return land
end

@doc """
sets interflow runoff to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffInterflow_none


---

# Extended help
"""
runoffInterflow_none