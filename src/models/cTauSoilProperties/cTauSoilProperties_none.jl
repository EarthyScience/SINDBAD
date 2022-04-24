export cTauSoilProperties_none

struct cTauSoilProperties_none <: cTauSoilProperties
end

function precompute(o::cTauSoilProperties_none, forcing, land, helpers)

	## calculate variables
	p_kfSoil = ones(helpers.numbers.numType, helpers.pools.carbon.nZix.cEco)

	## pack land variables
	@pack_land p_kfSoil => land.cTauSoilProperties
	return land
end

@doc """
Set soil texture effects to ones (ineficient, should be pix zix_mic)

# precompute:
precompute/instantiate time-invariant variables for cTauSoilProperties_none


---

# Extended help
"""
cTauSoilProperties_none