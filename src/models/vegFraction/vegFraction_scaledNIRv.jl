export vegFraction_scaledNIRv, vegFraction_scaledNIRv_h
"""
sets the value of vegFraction by scaling the NIRv value

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_scaledNIRv{T1} <: vegFraction
	NIRvscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NIRv" | ""
end

function precompute(o::vegFraction_scaledNIRv, forcing, land, infotem)
	# @unpack_vegFraction_scaledNIRv o
	return land
end

function compute(o::vegFraction_scaledNIRv, forcing, land, infotem)
	@unpack_vegFraction_scaledNIRv o

	## unpack variables
	@unpack_land begin
		NIRv ∈ land.states
	end
	vegFraction = min(NIRv * NIRvscale, 1)

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_scaledNIRv, forcing, land, infotem)
	# @unpack_vegFraction_scaledNIRv o
	return land
end

"""
sets the value of vegFraction by scaling the NIRv value

# precompute:
precompute/instantiate time-invariant variables for vegFraction_scaledNIRv

# compute:
Fractional coverage of vegetation using vegFraction_scaledNIRv

*Inputs:*
 - land.states.NIRv : current NIRv value

*Outputs:*
 - land.states.vegFraction: current vegetation fraction

# update
update pools and states in vegFraction_scaledNIRv
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.1 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function vegFraction_scaledNIRv_h end