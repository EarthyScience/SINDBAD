export runoffInfiltrationExcess_none

struct runoffInfiltrationExcess_none <: runoffInfiltrationExcess
end

function precompute(o::runoffInfiltrationExcess_none, forcing, land, infotem)

	## calculate variables
	runoffInfiltration = infotem.helpers.zero

	## pack land variables
	@pack_land runoffInfiltration => land.fluxes
	return land
end

@doc """
sets infiltration excess runoff to zeros

# precompute:
precompute/instantiate time-invariant variables for runoffInfiltrationExcess_none


---

# Extended help
"""
runoffInfiltrationExcess_none