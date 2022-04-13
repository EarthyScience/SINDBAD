export gppDiffRadiation_none, gppDiffRadiation_none_h
"""
set the cloudiness scalar [radiation diffusion] for gppPot to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppDiffRadiation_none{T} <: gppDiffRadiation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppDiffRadiation_none, forcing, land, infotem)
	@unpack_gppDiffRadiation_none o

	## calculate variables
	#--> set scalar to a constant one [no effect on potential GPP]
	CloudScGPP = 1.0

	## pack variables
	@pack_land begin
		CloudScGPP ∋ land.gppDiffRadiation
	end
	return land
end

function compute(o::gppDiffRadiation_none, forcing, land, infotem)
	# @unpack_gppDiffRadiation_none o
	return land
end

function update(o::gppDiffRadiation_none, forcing, land, infotem)
	# @unpack_gppDiffRadiation_none o
	return land
end

"""
set the cloudiness scalar [radiation diffusion] for gppPot to ones

# precompute:
precompute/instantiate time-invariant variables for gppDiffRadiation_none

# compute:
Effect of diffuse radiation using gppDiffRadiation_none

*Inputs:*
 - info

*Outputs:*
 - land.gppDiffRadiation.CloudScGPP: effect of cloudiness on potential GPP

# update
update pools and states in gppDiffRadiation_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - Martin Jung [mjung]
 - Nuno Carvalhais [ncarval]
"""
function gppDiffRadiation_none_h end