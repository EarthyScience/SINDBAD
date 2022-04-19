export aRespiration_none

struct aRespiration_none <: aRespiration
end

function precompute(o::aRespiration_none, forcing, land, infotem)

	## calculate variables
	zix = infotem.pools.carbon.zix.cVeg
	cEcoEfflux[zix] = infotem.helpers.zero

	## pack land variables
	@pack_land cEcoEfflux => land.states
	return land
end

@doc """
sets the outflow from all vegetation pools to zeros

# precompute:
precompute/instantiate time-invariant variables for aRespiration_none


---

# Extended help
"""
aRespiration_none