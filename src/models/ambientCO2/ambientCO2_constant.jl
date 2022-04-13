export ambientCO2_constant, ambientCO2_constant_h
"""
sets the value of ambCO2 as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct ambientCO2_constant{T1} <: ambientCO2
	constantambCO2::T1 = 400.0 | (200.0, 5000.0) | "atmospheric CO2 concentration" | "ppm"
end

function precompute(o::ambientCO2_constant, forcing, land, infotem)
	@unpack_ambientCO2_constant o

	## calculate variables
	ambCO2 = constantambCO2

	## pack variables
	@pack_land begin
		ambCO2 ∋ land.states
	end
	return land
end

function compute(o::ambientCO2_constant, forcing, land, infotem)
	# @unpack_ambientCO2_constant o
	return land
end

function update(o::ambientCO2_constant, forcing, land, infotem)
	# @unpack_ambientCO2_constant o
	return land
end

"""
sets the value of ambCO2 as a constant

# precompute:
precompute/instantiate time-invariant variables for ambientCO2_constant

# compute:
Set/get ambient co2 concentration using ambientCO2_constant

*Inputs:*

*Outputs:*
 - land.states.ambCO2: a constant state of ambient CO2

# update
update pools and states in ambientCO2_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function ambientCO2_constant_h end