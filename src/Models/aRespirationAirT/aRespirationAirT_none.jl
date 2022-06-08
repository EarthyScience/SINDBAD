export aRespirationAirT_none

struct aRespirationAirT_none <: aRespirationAirT
end

function precompute(o::aRespirationAirT_none, forcing, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	fT = helpers.numbers.𝟙

	## pack land variables
	@pack_land fT => land.aRespirationAirT
	return land
end

@doc """
sets the effect of temperature on RA to one [no effect]

# precompute:
precompute/instantiate time-invariant variables for aRespirationAirT_none


---

# Extended help
"""
aRespirationAirT_none