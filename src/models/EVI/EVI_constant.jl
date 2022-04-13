export EVI_constant, EVI_constant_h
"""
sets the value of EVI as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct EVI_constant{T1} <: EVI
	constantEVI::T1 = 1.0 | (0.0, 1.0) | "EVI" | ""
end

function precompute(o::EVI_constant, forcing, land, infotem)
	@unpack_EVI_constant o

	## calculate variables
	EVI = constantEVI

	## pack variables
	@pack_land begin
		EVI ∋ land.states
	end
	return land
end

function compute(o::EVI_constant, forcing, land, infotem)
	# @unpack_EVI_constant o
	return land
end

function update(o::EVI_constant, forcing, land, infotem)
	# @unpack_EVI_constant o
	return land
end

"""
sets the value of EVI as a constant

# precompute:
precompute/instantiate time-invariant variables for EVI_constant

# compute:
Enhanced vegetation index using EVI_constant

*Inputs:*

*Outputs:*
 - land.states.EVI: an extra forcing that creates a time series of constant EVI

# update
update pools and states in EVI_constant
 - land.states.EVI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function EVI_constant_h end