export cTauSoilProperties_none

struct cTauSoilProperties_none <: cTauSoilProperties
end

function instantiate(o::cTauSoilProperties_none, forcing, land, helpers)

	## calculate variables
	p_kfSoil = zero(land.pools.cEco) .+ helpers.numbers.𝟙

	## pack land variables
	@pack_land p_kfSoil => land.cTauSoilProperties
	return land
end

@doc """
Set soil texture effects to ones (ineficient, should be pix zix_mic)

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilProperties_none


---

# Extended help
"""
cTauSoilProperties_none