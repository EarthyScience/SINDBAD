export runoffSaturationExcess_wSoilSatFraction, runoffSaturationExcess_wSoilSatFraction_h
"""
calculate the saturation excess runoff as a fraction of

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSaturationExcess_wSoilSatFraction{T} <: runoffSaturationExcess
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffSaturationExcess_wSoilSatFraction, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_wSoilSatFraction o
	return land
end

function compute(o::runoffSaturationExcess_wSoilSatFraction, forcing, land, infotem)
	@unpack_runoffSaturationExcess_wSoilSatFraction o

	## unpack variables
	@unpack_land begin
		(WBP, soilWSatFrac) ∈ land.states
	end
	roSat = WBP * soilWSatFrac
	# update the WBP
	WBP = WBP - roSat

	## pack variables
	@pack_land begin
		roSat ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::runoffSaturationExcess_wSoilSatFraction, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_wSoilSatFraction o
	return land
end

"""
calculate the saturation excess runoff as a fraction of

# precompute:
precompute/instantiate time-invariant variables for runoffSaturationExcess_wSoilSatFraction

# compute:
Saturation runoff using runoffSaturationExcess_wSoilSatFraction

*Inputs:*
 - land.states.WBP: amount of incoming water
 - land.states.soilWSatFrac: fraction of the grid cell that is saturated

*Outputs:*
 - land.fluxes.roSat: saturation excess runoff in mm/day

# update
update pools and states in runoffSaturationExcess_wSoilSatFraction
 - land.states.WBP

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - only works if soilWSatFrac module is activated
"""
function runoffSaturationExcess_wSoilSatFraction_h end