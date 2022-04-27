export cTauLAI_none

struct cTauLAI_none <: cTauLAI
end

function precompute(o::cTauLAI_none, forcing, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	p_kfLAI = ones(helpers.numbers.numType, length(land.pools.cEco)); #(ineficient, should be pix zix_veg)

	## pack land variables
	@pack_land p_kfLAI => land.cTauLAI
	return land
end

@doc """
set values to ones

# precompute:
precompute/instantiate time-invariant variables for cTauLAI_none


---

# Extended help
"""
cTauLAI_none