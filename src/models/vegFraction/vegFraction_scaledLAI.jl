export vegFraction_scaledLAI, vegFraction_scaledLAI_h
"""
sets the value of vegFraction by scaling the LAI value

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_scaledLAI{T1} <: vegFraction
	LAIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for LAI" | ""
end

function precompute(o::vegFraction_scaledLAI, forcing, land, infotem)
	# @unpack_vegFraction_scaledLAI o
	return land
end

function compute(o::vegFraction_scaledLAI, forcing, land, infotem)
	@unpack_vegFraction_scaledLAI o

	## unpack variables
	@unpack_land begin
		LAI ∈ land.states
	end
	vegFraction = min(LAI * LAIscale, 1)

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_scaledLAI, forcing, land, infotem)
	# @unpack_vegFraction_scaledLAI o
	return land
end

"""
sets the value of vegFraction by scaling the LAI value

# precompute:
precompute/instantiate time-invariant variables for vegFraction_scaledLAI

# compute:
Fractional coverage of vegetation using vegFraction_scaledLAI

*Inputs:*
 - land.states.LAI : current LAI value

*Outputs:*
 - land.states.vegFraction: current vegetation fraction

# update
update pools and states in vegFraction_scaledLAI
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.1 on 24.10.2020 [ttraut]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function vegFraction_scaledLAI_h end