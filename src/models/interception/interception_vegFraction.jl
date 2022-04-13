export interception_vegFraction, interception_vegFraction_h
"""
computes canopy interception evaporation as a fraction of vegetation cover

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct interception_vegFraction{T1} <: interception
	pInt::T1 = 1.0 | (0.01, 5.0) | "maximum interception storage" | "mm"
end

function precompute(o::interception_vegFraction, forcing, land, infotem)
	# @unpack_interception_vegFraction o
	return land
end

function compute(o::interception_vegFraction, forcing, land, infotem)
	@unpack_interception_vegFraction o

	## unpack variables
	@unpack_land begin
		(WBP, vegFraction) ∈ land.states
		rain ∈ land.rainSnow
	end
	#--> calculate interception loss
	intCap = pInt * vegFraction
	interception = min(intCap, rain)
	# update the available water
	WBP = WBP - interception

	## pack variables
	@pack_land begin
		interception ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::interception_vegFraction, forcing, land, infotem)
	# @unpack_interception_vegFraction o
	return land
end

"""
computes canopy interception evaporation as a fraction of vegetation cover

# precompute:
precompute/instantiate time-invariant variables for interception_vegFraction

# compute:
Interception evaporation using interception_vegFraction

*Inputs:*
 - land.states.vegFraction

*Outputs:*
 -

# update
update pools and states in interception_vegFraction
 - land.states.WBP: updates the water balance pool [mm]

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 27.11.2019 [skoiralal]: moved contents from prec, handling of vegFraction from s.cd  

*Created by:*
 - Tina Trautmann [ttraut]
"""
function interception_vegFraction_h end