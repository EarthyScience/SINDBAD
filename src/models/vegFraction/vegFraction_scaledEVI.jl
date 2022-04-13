export vegFraction_scaledEVI, vegFraction_scaledEVI_h
"""
sets the value of vegFraction by scaling the EVI value

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_scaledEVI{T1} <: vegFraction
	EVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for EVI" | ""
end

function precompute(o::vegFraction_scaledEVI, forcing, land, infotem)
	# @unpack_vegFraction_scaledEVI o
	return land
end

function compute(o::vegFraction_scaledEVI, forcing, land, infotem)
	@unpack_vegFraction_scaledEVI o

	## unpack variables
	@unpack_land begin
		EVI ∈ land.states
	end
	vegFraction = min(EVI * EVIscale, 1)

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_scaledEVI, forcing, land, infotem)
	# @unpack_vegFraction_scaledEVI o
	return land
end

"""
sets the value of vegFraction by scaling the EVI value

# precompute:
precompute/instantiate time-invariant variables for vegFraction_scaledEVI

# compute:
Fractional coverage of vegetation using vegFraction_scaledEVI

*Inputs:*
 - land.states.EVI : current EVI value

*Outputs:*
 - land.states.vegFraction: current vegetation fraction

# update
update pools and states in vegFraction_scaledEVI
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 06.02.2020 [ttraut]  
 - 1.1 on 05.03.2020 [ttraut]: apply the min function

*Created by:*
 - Tina Trautmann [ttraut]
"""
function vegFraction_scaledEVI_h end