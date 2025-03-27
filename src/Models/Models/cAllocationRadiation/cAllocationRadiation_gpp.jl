export cAllocationRadiation_gpp

struct cAllocationRadiation_gpp <: cAllocationRadiation
end

function compute(o::cAllocationRadiation_gpp, forcing, land::NamedTuple, helpers::NamedTuple)

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
radiation effect on decomposition/mineralization = the same for GPP

---

# compute:

*Inputs*
 - land.gppDiffRadiation.CloudScGPP: radiation effect for GPP

*Outputs*
 - land.cAllocationRadiation.fR: radiation effect on decomposition/mineralization

---

# Extended help

*References*

*Versions*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
cAllocationRadiation_gpp