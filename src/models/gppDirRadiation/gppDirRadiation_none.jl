export gppDirRadiation_none, gppDirRadiation_none_h
"""
set the light saturation scalar [light effect] on gppPot to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppDirRadiation_none{T} <: gppDirRadiation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppDirRadiation_none, forcing, land, infotem)
	@unpack_gppDirRadiation_none o

	## calculate variables
	LightScGPP = 1.0

	## pack variables
	@pack_land begin
		LightScGPP ∋ land.gppDirRadiation
	end
	return land
end

function compute(o::gppDirRadiation_none, forcing, land, infotem)
	# @unpack_gppDirRadiation_none o
	return land
end

function update(o::gppDirRadiation_none, forcing, land, infotem)
	# @unpack_gppDirRadiation_none o
	return land
end

"""
set the light saturation scalar [light effect] on gppPot to ones

# precompute:
precompute/instantiate time-invariant variables for gppDirRadiation_none

# compute:
Effect of direct radiation using gppDirRadiation_none

*Inputs:*
 - info

*Outputs:*
 - land.gppDirRadiation.LightScGPP: effect of light saturation on potential GPP

# update
update pools and states in gppDirRadiation_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - Martin Jung [mjung]
 - Nuno Carvalhais [ncarval]
"""
function gppDirRadiation_none_h end