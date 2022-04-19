export transpiration_none

struct transpiration_none <: transpiration
end

function precompute(o::transpiration_none, forcing, land, infotem)

	## calculate variables
	transpiration = infotem.helpers.zero

	## pack land variables
	@pack_land transpiration => land.fluxes
	return land
end

@doc """
sets the actual transpiration to zeros

# precompute:
precompute/instantiate time-invariant variables for transpiration_none


---

# Extended help
"""
transpiration_none