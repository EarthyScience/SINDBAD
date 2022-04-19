export aRespirationAirT_none

struct aRespirationAirT_none <: aRespirationAirT
end

function precompute(o::aRespirationAirT_none, forcing, land, infotem)

	## calculate variables
	fT = infotem.helpers.one

	## pack land variables
	@pack_land fT => land.aRespirationAirT
	return land
end

@doc """
sets the effect of temperature on RA to none [ones = no effect]

# precompute:
precompute/instantiate time-invariant variables for aRespirationAirT_none


---

# Extended help
"""
aRespirationAirT_none