export cTauSoilT_none

struct cTauSoilT_none <: cTauSoilT
end

function precompute(o::cTauSoilT_none, forcing, land, infotem)

	## calculate variables
	fT = infotem.helpers.one

	## pack land variables
	@pack_land fT => land.cTauSoilT
	return land
end

@doc """
set the outputs to ones

# precompute:
precompute/instantiate time-invariant variables for cTauSoilT_none


---

# Extended help
"""
cTauSoilT_none