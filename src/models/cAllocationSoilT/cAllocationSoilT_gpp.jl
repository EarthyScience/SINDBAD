export cAllocationSoilT_gpp, cAllocationSoilT_gpp_h
"""
compute the temperature effect on C allocation to the same as gpp.

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilT_gpp{T} <: cAllocationSoilT
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationSoilT_gpp, forcing, land, infotem)
	# @unpack_cAllocationSoilT_gpp o
	return land
end

function compute(o::cAllocationSoilT_gpp, forcing, land, infotem)
	@unpack_cAllocationSoilT_gpp o

	## unpack variables
	@unpack_land begin
		TempScGPP ∈ land.gppAirT
	end
	# computation for the temperature effect on decomposition/mineralization
	fT = TempScGPP

	## pack variables
	@pack_land begin
		fT ∋ land.cAllocationSoilT
	end
	return land
end

function update(o::cAllocationSoilT_gpp, forcing, land, infotem)
	# @unpack_cAllocationSoilT_gpp o
	return land
end

"""
compute the temperature effect on C allocation to the same as gpp.

# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilT_gpp

# compute:
Effect of soil temperature on carbon allocation using cAllocationSoilT_gpp

*Inputs:*
 - land.gppAirT.TempScGPP: temperature stressors on GPP

*Outputs:*
 - land.cAllocationSoilT.fT: values for the temperature effect on decomposition/mineralization

# update
update pools and states in cAllocationSoilT_gpp
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 26.01.2021 [skoirala]  

*Created by:*
 - skoirala
"""
function cAllocationSoilT_gpp_h end