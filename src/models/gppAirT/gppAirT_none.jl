export gppAirT_none, gppAirT_none_h
"""
set the temperature stress on gppPot to ones (no stress)

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppAirT_none{T} <: gppAirT
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gppAirT_none, forcing, land, infotem)
	@unpack_gppAirT_none o

	## calculate variables
	#--> set scalar to a constant one [no effect on potential GPP]
	TempScGPP = 1.0

	## pack variables
	@pack_land begin
		TempScGPP ∋ land.gppAirT
	end
	return land
end

function compute(o::gppAirT_none, forcing, land, infotem)
	# @unpack_gppAirT_none o
	return land
end

function update(o::gppAirT_none, forcing, land, infotem)
	# @unpack_gppAirT_none o
	return land
end

"""
set the temperature stress on gppPot to ones (no stress)

# precompute:
precompute/instantiate time-invariant variables for gppAirT_none

# compute:
Effect of temperature using gppAirT_none

*Inputs:*
 - info

*Outputs:*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP

# update
update pools and states in gppAirT_none
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]
"""
function gppAirT_none_h end