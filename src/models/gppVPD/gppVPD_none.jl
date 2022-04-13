export gppVPD_none, gppVPD_none_h
"""
set the VPD stress on gppPot to ones (no stress)

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppVPD_none{T} <: gppVPD
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppVPD_none, forcing, land, infotem)
	@unpack_gppVPD_none o

	## calculate variables
	#--> set scalar to a constant one [no effect on potential GPP]
	VPDScGPP = 1.0

	## pack variables
	@pack_land begin
		VPDScGPP ∋ land.gppVPD
	end
	return land
end

function compute(o::gppVPD_none, forcing, land, infotem)
	# @unpack_gppVPD_none o
	return land
end

function update(o::gppVPD_none, forcing, land, infotem)
	# @unpack_gppVPD_none o
	return land
end

"""
set the VPD stress on gppPot to ones (no stress)

# precompute:
precompute/instantiate time-invariant variables for gppVPD_none

# compute:
Vpd effect using gppVPD_none

*Inputs:*
 - info

*Outputs:*
 - land.gppVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1

# update
update pools and states in gppVPD_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]
"""
function gppVPD_none_h end