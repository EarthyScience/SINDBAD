export fAPAR_constant, fAPAR_constant_h
"""
sets the value of fAPAR as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct fAPAR_constant{T1} <: fAPAR
	constantfAPAR::T1 = 0.2 | (0.0, 1.0) | "a constant fAPAR" | ""
end

function precompute(o::fAPAR_constant, forcing, land, infotem)
	@unpack_fAPAR_constant o

	## calculate variables
	fAPAR = constantfAPAR

	## pack variables
	@pack_land begin
		fAPAR ∋ land.states
	end
	return land
end

function compute(o::fAPAR_constant, forcing, land, infotem)
	# @unpack_fAPAR_constant o
	return land
end

function update(o::fAPAR_constant, forcing, land, infotem)
	# @unpack_fAPAR_constant o
	return land
end

"""
sets the value of fAPAR as a constant

# precompute:
precompute/instantiate time-invariant variables for fAPAR_constant

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_constant

*Inputs:*
 - info helper for array

*Outputs:*
 - land.states.fAPAR: an extra forcing that creates a time series of constant fAPAR

# update
update pools and states in fAPAR_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function fAPAR_constant_h end