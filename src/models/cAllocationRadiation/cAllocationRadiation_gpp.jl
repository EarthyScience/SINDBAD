export cAllocationRadiation_gpp, cAllocationRadiation_gpp_h
"""
computation for the radiation effect on decomposition/mineralization as the same for GPP

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationRadiation_gpp{T} <: cAllocationRadiation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationRadiation_gpp, forcing, land, infotem)
	# @unpack_cAllocationRadiation_gpp o
	return land
end

function compute(o::cAllocationRadiation_gpp, forcing, land, infotem)
	@unpack_cAllocationRadiation_gpp o

	## unpack variables
	@unpack_land begin
		CloudScGPP ∈ land.gppDiffRadiation
	end
	# computation for the radiation effect on decomposition/mineralization
	fR = CloudScGPP

	## pack variables
	@pack_land begin
		fR ∋ land.cAllocationRadiation
	end
	return land
end

function update(o::cAllocationRadiation_gpp, forcing, land, infotem)
	# @unpack_cAllocationRadiation_gpp o
	return land
end

"""
computation for the radiation effect on decomposition/mineralization as the same for GPP

# precompute:
precompute/instantiate time-invariant variables for cAllocationRadiation_gpp

# compute:
Effect of radiation on carbon allocation using cAllocationRadiation_gpp

*Inputs:*
 - land.gppDiffRadiation.CloudScGPP: light scalar for GPP

*Outputs:*
 - land.cAllocationRadiation.fR: values for the radiation effect on decomposition/mineralization

# update
update pools and states in cAllocationRadiation_gpp
 - land.cAllocationRadiation.fR

# Extended help

*References:*

*Versions:*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
function cAllocationRadiation_gpp_h end