export vegFraction_scaledfAPAR, vegFraction_scaledfAPAR_h
"""
sets the value of vegFraction by scaling the fAPAR value

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_scaledfAPAR{T1} <: vegFraction
	fAPARscale::T1 = 10.0 | (0.0, 20.0) | "scalar for fAPAR" | ""
end

function precompute(o::vegFraction_scaledfAPAR, forcing, land, infotem)
	# @unpack_vegFraction_scaledfAPAR o
	return land
end

function compute(o::vegFraction_scaledfAPAR, forcing, land, infotem)
	@unpack_vegFraction_scaledfAPAR o

	## unpack variables
	@unpack_land begin
		fAPAR ∈ land.states
	end
	vegFraction = min(fAPAR * fAPARscale, 1)

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_scaledfAPAR, forcing, land, infotem)
	# @unpack_vegFraction_scaledfAPAR o
	return land
end

"""
sets the value of vegFraction by scaling the fAPAR value

# precompute:
precompute/instantiate time-invariant variables for vegFraction_scaledfAPAR

# compute:
Fractional coverage of vegetation using vegFraction_scaledfAPAR

*Inputs:*
 - land.states.fAPAR : current fAPAR value

*Outputs:*
 - land.states.vegFraction: current vegetation fraction

# update
update pools and states in vegFraction_scaledfAPAR
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.1 on 24.10.2020 [ttraut]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function vegFraction_scaledfAPAR_h end