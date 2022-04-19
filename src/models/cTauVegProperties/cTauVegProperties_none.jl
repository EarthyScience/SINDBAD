export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties
end

function precompute(o::cTauVegProperties_none, forcing, land, infotem)

	## calculate variables
	p_kfVeg = repeat(infotem.helpers.aone, infotem.pools.water.nZix.cEco)
	p_LITC2N = infotem.helpers.zero
	p_LIGNIN = infotem.helpers.zero
	p_MTF = infotem.helpers.one
	p_SCLIGNIN = infotem.helpers.zero
	p_LIGEFF = infotem.helpers.zero

	## pack land variables
	@pack_land (p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_kfVeg) => land.cTauVegProperties
	return land
end

@doc """
set the outputs to ones

# precompute:
precompute/instantiate time-invariant variables for cTauVegProperties_none


---

# Extended help
"""
cTauVegProperties_none