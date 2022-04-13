export interception_fAPAR, interception_fAPAR_h
"""
computes canopy interception evaporation as a fraction of fAPAR

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct interception_fAPAR{T1} <: interception
	isp::T1 = 1.0 | (0.1, 5.0) | "fapar dependent storage" | ""
end

function precompute(o::interception_fAPAR, forcing, land, infotem)
	# @unpack_interception_fAPAR o
	return land
end

function compute(o::interception_fAPAR, forcing, land, infotem)
	@unpack_interception_fAPAR o

	## unpack variables
	@unpack_land begin
		(WBP, fAPAR) ∈ land.states
		rain ∈ land.rainSnow
	end
	#--> calculate interception loss
	intCap = isp * fAPAR
	interception = min(intCap, rain)
	#--> update the available water
	WBP = WBP - interception

	## pack variables
	@pack_land begin
		interception ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::interception_fAPAR, forcing, land, infotem)
	# @unpack_interception_fAPAR o
	return land
end

"""
computes canopy interception evaporation as a fraction of fAPAR

# precompute:
precompute/instantiate time-invariant variables for interception_fAPAR

# compute:
Interception evaporation using interception_fAPAR

*Inputs:*
 - land.states.fAPAR: fAPAR

*Outputs:*
 - land.fluxes.interception: interception loss

# update
update pools and states in interception_fAPAR
 - land.states.WBP: water balance pool [mm]

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 29.11.2019 [skoirala]: land.states.fAPAR  

*Created by:*
 - Martin Jung [mjung]
"""
function interception_fAPAR_h end