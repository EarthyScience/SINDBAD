export saturatedFraction_none

struct saturatedFraction_none <: saturatedFraction
end

function precompute(o::saturatedFraction_none, forcing, land, infotem)

	## calculate variables
	soilWSatFrac = infotem.helpers.zero

	## pack land variables
	@pack_land soilWSatFrac => land.states
	return land
end

@doc """
sets the land.states.soilWSatFrac [saturated soil fraction] to zeros (pix, 1)

# precompute:
precompute/instantiate time-invariant variables for saturatedFraction_none


---

# Extended help
"""
saturatedFraction_none