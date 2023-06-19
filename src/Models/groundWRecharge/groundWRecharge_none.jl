export groundWRecharge_none

struct groundWRecharge_none <: groundWRecharge
end

function instantiate(o::groundWRecharge_none, forcing, land, helpers)

	## calculate variables
	groundWRec = helpers.numbers.𝟘

	## pack land variables
	@pack_land groundWRec => land.fluxes
	return land
end

@doc """
sets the GW recharge to zero

# instantiate:
instantiate/instantiate time-invariant variables for groundWRecharge_none


---

# Extended help
"""
groundWRecharge_none