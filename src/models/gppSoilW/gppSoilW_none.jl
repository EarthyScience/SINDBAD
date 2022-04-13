export gppSoilW_none, gppSoilW_none_h
"""
set the soil moisture stress on gppPot to ones (no stress)

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppSoilW_none{T} <: gppSoilW
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppSoilW_none, forcing, land, infotem)
	@unpack_gppSoilW_none o

	## calculate variables
	#--> set scalar to a constant one [no effect on potential GPP]
	SMScGPP = 1.0

	## pack variables
	@pack_land begin
		SMScGPP ∋ land.gppSoilW
	end
	return land
end

function compute(o::gppSoilW_none, forcing, land, infotem)
	# @unpack_gppSoilW_none o
	return land
end

function update(o::gppSoilW_none, forcing, land, infotem)
	# @unpack_gppSoilW_none o
	return land
end

"""
set the soil moisture stress on gppPot to ones (no stress)

# precompute:
precompute/instantiate time-invariant variables for gppSoilW_none

# compute:
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_none

*Inputs:*
 - info

*Outputs:*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP [] dimensionless, between 0-1

# update
update pools and states in gppSoilW_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]
"""
function gppSoilW_none_h end