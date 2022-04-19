export cFlowVegProperties_none

struct cFlowVegProperties_none <: cFlowVegProperties
end

function precompute(o::cFlowVegProperties_none, forcing, land, infotem)

	## calculate variables
	p_F = repeat(repeat(infotem.helpers.azero, infotem.pools.carbon.nZix.cEco), 1, 1, infotem.pools.carbon.nZix.cEco)
	p_E = p_F

	## pack land variables
	@pack_land (p_E, p_F) => land.cFlowVegProperties
	return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# precompute:
precompute/instantiate time-invariant variables for cFlowVegProperties_none


---

# Extended help
"""
cFlowVegProperties_none