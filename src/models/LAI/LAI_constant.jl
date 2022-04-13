export LAI_constant, LAI_constant_h
"""
sets the value of LAI as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct LAI_constant{T1} <: LAI
	constantLAI::T1 = 3.0 | (1.0, 12.0) | "LAI" | "m2/m2"
end

function precompute(o::LAI_constant, forcing, land, infotem)
	@unpack_LAI_constant o

	## calculate variables
	LAI = constantLAI

	## pack variables
	@pack_land begin
		LAI ∋ land.states
	end
	return land
end

function compute(o::LAI_constant, forcing, land, infotem)
	# @unpack_LAI_constant o
	return land
end

function update(o::LAI_constant, forcing, land, infotem)
	# @unpack_LAI_constant o
	return land
end

"""
sets the value of LAI as a constant

# precompute:
precompute/instantiate time-invariant variables for LAI_constant

# compute:
Leaf area index using LAI_constant

*Inputs:*

*Outputs:*
 - land.states.LAI: an extra forcing that creates a time series of constant LAI

# update
update pools and states in LAI_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function LAI_constant_h end