export NIRv_constant, NIRv_constant_h
"""
sets the value of NIRv as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct NIRv_constant{T1} <: NIRv
	constantNIRv::T1 = 1.0 | (0.0, 1.0) | "NIRv" | ""
end

function precompute(o::NIRv_constant, forcing, land, infotem)
	@unpack_NIRv_constant o

	## calculate variables
	NIRv = constantNIRv

	## pack variables
	@pack_land begin
		NIRv ∋ land.states
	end
	return land
end

function compute(o::NIRv_constant, forcing, land, infotem)
	# @unpack_NIRv_constant o
	return land
end

function update(o::NIRv_constant, forcing, land, infotem)
	# @unpack_NIRv_constant o
	return land
end

"""
sets the value of NIRv as a constant

# precompute:
precompute/instantiate time-invariant variables for NIRv_constant

# compute:
Near-infrared reflectance of terrestrial vegetation using NIRv_constant

*Inputs:*

*Outputs:*
 - land.states.NIRv: an extra forcing that creates a time series of constant NIRv

# update
update pools and states in NIRv_constant
 - land.states.NIRv

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function NIRv_constant_h end