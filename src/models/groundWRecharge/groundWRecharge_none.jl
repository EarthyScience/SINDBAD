export groundWRecharge_none

struct groundWRecharge_none <: groundWRecharge
end

function precompute(o::groundWRecharge_none, forcing, land, infotem)

	## calculate variables
	gwRec = infotem.helpers.zero

	## pack land variables
	@pack_land gwRec => land.fluxes
	return land
end

@doc """
set the GW recharge to zeros

# precompute:
precompute/instantiate time-invariant variables for groundWRecharge_none


---

# Extended help
"""
groundWRecharge_none