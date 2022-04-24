export cTau_none

struct cTau_none <: cTau
end

function precompute(o::cTau_none, forcing, land, helpers)

	## calculate variables
	p_k = ones(helpers.numbers.numType, helpers.pools.carbon.nZix.cEco)

	## pack land variables
	@pack_land p_k => land.cTau
	return land
end

@doc """
set the actual τ to ones

# precompute:
precompute/instantiate time-invariant variables for cTau_none


---

# Extended help
"""
cTau_none