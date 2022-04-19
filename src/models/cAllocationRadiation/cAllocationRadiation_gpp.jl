export cAllocationRadiation_gpp

struct cAllocationRadiation_gpp <: cAllocationRadiation
end

function compute(o::cAllocationRadiation_gpp, forcing, land, infotem)

	## unpack land variables
	@unpack_land CloudScGPP ∈ land.gppDiffRadiation


	## calculate variables
	# computation for the radiation effect on decomposition/mineralization
	fR = CloudScGPP

	## pack land variables
	@pack_land fR => land.cAllocationRadiation
	return land
end

@doc """
computation for the radiation effect on decomposition/mineralization as the same for GPP

---

# compute:
Effect of radiation on carbon allocation using cAllocationRadiation_gpp

*Inputs*
 - land.gppDiffRadiation.CloudScGPP: light scalar for GPP

*Outputs*
 - land.cAllocationRadiation.fR: values for the radiation effect on decomposition/mineralization
 - land.cAllocationRadiation.fR

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationRadiation_gpp