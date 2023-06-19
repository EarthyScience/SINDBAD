export cTauLAI_none

struct cTauLAI_none <: cTauLAI
end

function instantiate(o::cTauLAI_none, forcing, land, helpers)

	## calculate variables
	p_kfLAI = zero(land.pools.cEco) .+ helpers.numbers.𝟙; #(ineficient, should be pix zix_veg)

	## pack land variables
	@pack_land p_kfLAI => land.cTauLAI
	return land
end

@doc """
set values to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauLAI_none


---

# Extended help
"""
cTauLAI_none