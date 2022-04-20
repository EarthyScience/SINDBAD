export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties
end

function precompute(o::cTauVegProperties_none, forcing, land, helpers)

	## calculate variables
	p_kfVeg = ones(helpers.numbers.numType, helpers.pools.water.nZix.cEco)
	p_LITC2N = helpers.numbers.zero
	p_LIGNIN = helpers.numbers.zero
	p_MTF = helpers.numbers.one
	p_SCLIGNIN = helpers.numbers.zero
	p_LIGEFF = helpers.numbers.zero

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