export runoffSaturationExcess_none

struct runoffSaturationExcess_none <: runoffSaturationExcess
end

function precompute(o::runoffSaturationExcess_none, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	runoffSatExc = helpers.numbers.𝟘

	## pack land variables
	@pack_land runoffSatExc => land.fluxes
	return land
end

@doc """
set the saturation excess runoff to zero

# precompute:
precompute/instantiate time-invariant variables for runoffSaturationExcess_none


---

# Extended help
"""
runoffSaturationExcess_none