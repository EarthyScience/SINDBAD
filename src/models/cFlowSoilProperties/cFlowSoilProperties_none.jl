export cFlowSoilProperties_none

struct cFlowSoilProperties_none <: cFlowSoilProperties
end

function precompute(o::cFlowSoilProperties_none, forcing, land, helpers)

	## calculate variables
	p_E = repeat(zeros(helpers.numbers.numType, helpers.pools.water.nZix.cEco), 1, 1, helpers.pools.carbon.nZix.cEco)
	p_F = p_E

	## pack land variables
	@pack_land (p_E, p_F) => land.cFlowSoilProperties
	return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# precompute:
precompute/instantiate time-invariant variables for cFlowSoilProperties_none


---

# Extended help
"""
cFlowSoilProperties_none