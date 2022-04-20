export groundWSoilWInteraction_none

struct groundWSoilWInteraction_none <: groundWSoilWInteraction
end

function precompute(o::groundWSoilWInteraction_none, forcing, land, helpers)

	## calculate variables
	gwCflux = helpers.numbers.zero

	## pack land variables
	@pack_land gwCflux => land.fluxes
	return land
end

@doc """
sets the groundwater capillary flux to zeros

# precompute:
precompute/instantiate time-invariant variables for groundWSoilWInteraction_none


---

# Extended help
"""
groundWSoilWInteraction_none