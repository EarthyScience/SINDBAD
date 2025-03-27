export cTauSoilT_none

struct cTauSoilT_none <: cTauSoilT
end

function precompute(o::cTauSoilT_none, forcing, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	fT = helpers.numbers.𝟙

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