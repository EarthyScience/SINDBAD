export treeFraction_constant, treeFraction_constant_h
"""
sets the value of treeFraction as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct treeFraction_constant{T1} <: treeFraction
	constantTreeFrac::T1 = 0.5 | (0.3, 0.9) | "Tree fraction" | ""
end

function precompute(o::treeFraction_constant, forcing, land, infotem)
	@unpack_treeFraction_constant o

	## calculate variables
	treeFraction = constantTreeFrac

	## pack variables
	@pack_land begin
		treeFraction ∋ land.states
	end
	return land
end

function compute(o::treeFraction_constant, forcing, land, infotem)
	# @unpack_treeFraction_constant o
	return land
end

function update(o::treeFraction_constant, forcing, land, infotem)
	# @unpack_treeFraction_constant o
	return land
end

"""
sets the value of treeFraction as a constant

# precompute:
precompute/instantiate time-invariant variables for treeFraction_constant

# compute:
Fractional coverage of trees using treeFraction_constant

*Inputs:*
 - info helper for array

*Outputs:*
 - land.states.treeFraction: an extra forcing that creates a time series of constant treeFraction

# update
update pools and states in treeFraction_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function treeFraction_constant_h end