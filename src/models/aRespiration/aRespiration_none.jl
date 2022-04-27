export aRespiration_none

struct aRespiration_none <: aRespiration
end

function precompute(o::aRespiration_none, forcing, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	zix = helpers.pools.carbon.zix.cVeg
	cEcoEfflux[zix] = helpers.numbers.𝟘

	## pack land variables
	@pack_land cEcoEfflux => land.states
	return land
end

@doc """
sets the outflow from all vegetation pools to zero

# precompute:
precompute/instantiate time-invariant variables for aRespiration_none


---

# Extended help
"""
aRespiration_none