export vegFraction_constant, vegFraction_constant_h
"""
sets the value of vegFraction as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_constant{T1} <: vegFraction
	constantVegFrac::T1 = 0.5 | (0.3, 0.9) | "Vegetation fraction" | ""
end

function precompute(o::vegFraction_constant, forcing, land, infotem)
	@unpack_vegFraction_constant o

	## calculate variables
	vegFraction = constantVegFrac

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function compute(o::vegFraction_constant, forcing, land, infotem)
	# @unpack_vegFraction_constant o
	return land
end

function update(o::vegFraction_constant, forcing, land, infotem)
	# @unpack_vegFraction_constant o
	return land
end

"""
sets the value of vegFraction as a constant

# precompute:
precompute/instantiate time-invariant variables for vegFraction_constant

# compute:
Fractional coverage of vegetation using vegFraction_constant

*Inputs:*
 - constantvegFraction
 - info helper for array

*Outputs:*
 - land.states.vegFraction: an extra forcing that creates a time series of constant vegFraction

# update
update pools and states in vegFraction_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function vegFraction_constant_h end