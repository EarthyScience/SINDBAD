export cAllocationSoilT_gpp

struct cAllocationSoilT_gpp <: cAllocationSoilT
end

function compute(o::cAllocationSoilT_gpp, forcing, land, helpers)

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
compute the temperature effect on C allocation to the same as gpp.

---

# compute:
Effect of soil temperature on carbon allocation using cAllocationSoilT_gpp

*Inputs*
 - land.gppAirT.TempScGPP: temperature stressors on GPP

*Outputs*
 - land.cAllocationSoilT.fT: values for the temperature effect on decomposition/mineralization
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationSoilT_gpp