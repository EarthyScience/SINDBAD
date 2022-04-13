export runoffInfiltrationExcess_Jung, runoffInfiltrationExcess_Jung_h
"""
compute infiltration excess runoff

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffInfiltrationExcess_Jung{T} <: runoffInfiltrationExcess
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffInfiltrationExcess_Jung, forcing, land, infotem)
	# @unpack_runoffInfiltrationExcess_Jung o
	return land
end

function compute(o::runoffInfiltrationExcess_Jung, forcing, land, infotem)
	@unpack_runoffInfiltrationExcess_Jung o

	## unpack variables
	@unpack_land begin
		(WBP, fAPAR) ∈ land.states
		p_kSat ∈ land.soilWBase
		rain ∈ land.rainSnow
		rainInt ∈ land.rainIntensity
	end
	# we assume that infiltration capacity is unlimited in the vegetated
	# fraction [infiltration flux = P*fpar] the infiltration flux for the
	# unvegetated fraction is given as the minimum of the precip & the min of
	# precip intensity [P] & infiltration capacity [I] scaled with rain
	# duration [P/R]
	#--> get infiltration capacity of the first layer
	pInfCapacity = p_kSat[1] / 24; # in mm/hr
	roInf = 0.0
	tmp = rain > 0.0
	roInf[tmp] = rain[tmp] - (rain[tmp] * fAPAR[tmp] + (1.0 - fAPAR[tmp]) * min(rain[tmp], min(pInfCapacity[tmp], rainInt[tmp]) * rain[tmp] / rainInt[tmp]))
	WBP = WBP - roInf

	## pack variables
	@pack_land begin
		roInf ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::runoffInfiltrationExcess_Jung, forcing, land, infotem)
	# @unpack_runoffInfiltrationExcess_Jung o
	return land
end

"""
compute infiltration excess runoff

# precompute:
precompute/instantiate time-invariant variables for runoffInfiltrationExcess_Jung

# compute:
Infiltration excess runoff using runoffInfiltrationExcess_Jung

*Inputs:*
 - land.rainIntensity.rainInt: rain intensity [mm/h]
 - land.rainSnow.rain : rainfall [mm/time]
 - land.soilWBase.p_kSat: infiltration capacity [mm/day]
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  (equivalent to "canopy cover" in Gash & Miralles)

*Outputs:*
 - land.fluxes.roInf: infiltration excess runoff [mm/time] - what runs off because  the precipitation intensity is to high for it to inflitrate in  the soil

# update
update pools and states in runoffInfiltrationExcess_Jung
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 22.11.2019 [skoirala]: moved from prec to dyna to handle land.states.fAPAR which is nPix, 1  

*Created by:*
 - Martin Jung [mjung]
"""
function runoffInfiltrationExcess_Jung_h end