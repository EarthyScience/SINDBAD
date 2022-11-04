export cAllocationSoilT_gpp

struct cAllocationSoilT_gpp <: cAllocationSoilT
end

function precompute(o::cAllocationSoilT_gpp, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)

	## calculate variables
	# computation for the temperature effect on decomposition/mineralization
	fT = helpers.numbers.𝟙
	## pack land variables
	@pack_land fT => land.cAllocationSoilT
	return land
end

function compute(o::cAllocationSoilT_gpp, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land TempScGPP ∈ land.gppAirT

	## calculate variables
	# computation for the temperature effect on decomposition/mineralization
	fT = TempScGPP

	## pack land variables
	@pack_land fT => land.cAllocationSoilT
	return land
end

@doc """
temperature effect on allocation = the same as gpp

---

# compute:

*Inputs*
 - land.gppAirT.TempScGPP: temperature stressors on GPP

*Outputs*
 - land.cAllocationSoilT.fT: temperature effect on decomposition/mineralization

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationSoilT_gpp