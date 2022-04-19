export runoffSaturationExcess_none

struct runoffSaturationExcess_none <: runoffSaturationExcess
end

function precompute(o::runoffSaturationExcess_none, forcing, land, infotem)

	## calculate variables
	runoffSaturation = infotem.helpers.zero

	## pack land variables
	@pack_land runoffSaturation => land.fluxes
	return land
end

@doc """
set the saturation excess runoff to zeros

# precompute:
precompute/instantiate time-invariant variables for runoffSaturationExcess_none


---

# Extended help
"""
runoffSaturationExcess_none