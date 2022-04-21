export groundWSoilWInteraction_none

struct groundWSoilWInteraction_none <: groundWSoilWInteraction
end

function precompute(o::groundWSoilWInteraction_none, forcing, land, helpers)

	## calculate variables
	gwCapFlow = helpers.numbers.zero

	## pack land variables
	@pack_land gwCapFlow => land.fluxes
	return land
end

@doc """
sets the groundwater capillary flux to zero

# precompute:
precompute/instantiate time-invariant variables for groundWSoilWInteraction_none


---

# Extended help
"""
groundWSoilWInteraction_none