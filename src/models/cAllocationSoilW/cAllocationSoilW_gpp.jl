export cAllocationSoilW_gpp, cAllocationSoilW_gpp_h
"""
set the moisture effect on C allocation to the same as gpp from GSI approach.

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilW_gpp{T} <: cAllocationSoilW
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationSoilW_gpp, forcing, land, infotem)
	# @unpack_cAllocationSoilW_gpp o
	return land
end

function compute(o::cAllocationSoilW_gpp, forcing, land, infotem)
	@unpack_cAllocationSoilW_gpp o

	## unpack variables
	@unpack_land begin
		SMScGPP ∈ land.gppSoilW
	end
	# computation for the moisture effect on decomposition/mineralization
	fW = SMScGPP

	## pack variables
	@pack_land begin
		fW ∋ land.cAllocationSoilW
	end
	return land
end

function update(o::cAllocationSoilW_gpp, forcing, land, infotem)
	# @unpack_cAllocationSoilW_gpp o
	return land
end

"""
set the moisture effect on C allocation to the same as gpp from GSI approach.

# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilW_gpp

# compute:
Effect of soil moisture on carbon allocation using cAllocationSoilW_gpp

*Inputs:*
 - land.gppSoilW.SMScGPP: moisture stressors on GPP

*Outputs:*
 - land.cAllocationSoilW.fW: values for the moisture effect  on decomposition/mineralization

# update
update pools and states in cAllocationSoilW_gpp
 - land.cAllocationSoilW.fW

# Extended help

*References:*

*Versions:*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
function cAllocationSoilW_gpp_h end