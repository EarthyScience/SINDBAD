export NDVI_constant, NDVI_constant_h
"""
sets the value of NDVI as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct NDVI_constant{T1} <: NDVI
	constantNDVI::T1 = 1.0 | (0.0, 1.0) | "NDVI" | ""
end

function precompute(o::NDVI_constant, forcing, land, infotem)
	@unpack_NDVI_constant o

	## calculate variables
	NDVI = constantNDVI

	## pack variables
	@pack_land begin
		NDVI ∋ land.states
	end
	return land
end

function compute(o::NDVI_constant, forcing, land, infotem)
	# @unpack_NDVI_constant o
	return land
end

function update(o::NDVI_constant, forcing, land, infotem)
	# @unpack_NDVI_constant o
	return land
end

"""
sets the value of NDVI as a constant

# precompute:
precompute/instantiate time-invariant variables for NDVI_constant

# compute:
Normalized difference vegetation index using NDVI_constant

*Inputs:*

*Outputs:*
 - land.states.NDVI: an extra forcing that creates a time series of constant NDVI

# update
update pools and states in NDVI_constant
 - land.states.NDVI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function NDVI_constant_h end