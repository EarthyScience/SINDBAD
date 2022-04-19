export cAllocationSoilW_gpp

struct cAllocationSoilW_gpp <: cAllocationSoilW
end

function compute(o::cAllocationSoilW_gpp, forcing, land, infotem)

	## unpack land variables
	@unpack_land SMScGPP ∈ land.gppSoilW


	## calculate variables
	# computation for the moisture effect on decomposition/mineralization
	fW = SMScGPP

	## pack land variables
	@pack_land fW => land.cAllocationSoilW
	return land
end

@doc """
set the moisture effect on C allocation to the same as gpp from GSI approach.

---

# compute:
Effect of soil moisture on carbon allocation using cAllocationSoilW_gpp

*Inputs*
 - land.gppSoilW.SMScGPP: moisture stressors on GPP

*Outputs*
 - land.cAllocationSoilW.fW: values for the moisture effect  on decomposition/mineralization
 - land.cAllocationSoilW.fW

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationSoilW_gpp