export cTau_none

struct cTau_none <: cTau
end

function instantiate(o::cTau_none, forcing, land, helpers)

	## calculate variables
	p_k = ones(helpers.numbers.numType, length(land.pools.cEco))

	## pack land variables
	@pack_land p_k => land.cTau
	return land
end

@doc """
set the actual τ to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTau_none


---

# Extended help
"""
cTau_none