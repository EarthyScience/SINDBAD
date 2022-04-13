export vegFraction_scaledNDVI, vegFraction_scaledNDVI_h
"""
sets the value of vegFraction by scaling the NDVI value

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_scaledNDVI{T1} <: vegFraction
	NDVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NDVI" | ""
end

function precompute(o::vegFraction_scaledNDVI, forcing, land, infotem)
	# @unpack_vegFraction_scaledNDVI o
	return land
end

function compute(o::vegFraction_scaledNDVI, forcing, land, infotem)
	@unpack_vegFraction_scaledNDVI o

	## unpack variables
	@unpack_land begin
		NDVI ∈ land.states
	end
	vegFraction = min(NDVI * NDVIscale, 1)

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_scaledNDVI, forcing, land, infotem)
	# @unpack_vegFraction_scaledNDVI o
	return land
end

"""
sets the value of vegFraction by scaling the NDVI value

# precompute:
precompute/instantiate time-invariant variables for vegFraction_scaledNDVI

# compute:
Fractional coverage of vegetation using vegFraction_scaledNDVI

*Inputs:*
 - land.states.NDVI : current NDVI value

*Outputs:*
 - land.states.vegFraction: current vegetation fraction

# update
update pools and states in vegFraction_scaledNDVI
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.1 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function vegFraction_scaledNDVI_h end