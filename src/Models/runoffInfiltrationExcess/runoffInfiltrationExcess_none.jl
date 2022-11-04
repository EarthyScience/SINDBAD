export runoffInfiltrationExcess_none

struct runoffInfiltrationExcess_none <: runoffInfiltrationExcess
end

function precompute(o::runoffInfiltrationExcess_none, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	runoffInfExc = helpers.numbers.𝟘

	## pack land variables
	@pack_land runoffInfExc => land.fluxes
	return land
end

@doc """
sets infiltration excess runoff to zero

# precompute:
precompute/instantiate time-invariant variables for runoffInfiltrationExcess_none


---

# Extended help
"""
runoffInfiltrationExcess_none