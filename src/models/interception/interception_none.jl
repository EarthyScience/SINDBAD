export interception_none

struct interception_none <: interception
end

function precompute(o::interception_none, forcing, land, infotem)

	## calculate variables
	interception = infotem.helpers.zero

	## pack land variables
	@pack_land interception => land.fluxes
	return land
end

@doc """
sets the interception evaporation to zeros

# precompute:
precompute/instantiate time-invariant variables for interception_none


---

# Extended help
"""
interception_none