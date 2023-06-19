export cTauSoilW_none

struct cTauSoilW_none <: cTauSoilW
end

function instantiate(o::cTauSoilW_none, forcing, land, helpers)

	## calculate variables
	p_fsoilW = ones(helpers.numbers.numType, length(land.pools.cEco))

	## pack land variables
	@pack_land p_fsoilW => land.cTauSoilW
	return land
end

@doc """
set the moisture stress for all carbon pools to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilW_none


---

# Extended help
"""
cTauSoilW_none