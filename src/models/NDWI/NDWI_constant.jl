export NDWI_constant, NDWI_constant_h
"""
sets the value of NDWI as a constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct NDWI_constant{T1} <: NDWI
	constantNDWI::T1 = 1.0 | (0.0, 1.0) | "NDWI" | ""
end

function precompute(o::NDWI_constant, forcing, land, infotem)
	@unpack_NDWI_constant o

	## calculate variables
	NDWI = constantNDWI

	## pack variables
	@pack_land begin
		NDWI ∋ land.states
	end
	return land
end

function compute(o::NDWI_constant, forcing, land, infotem)
	# @unpack_NDWI_constant o
	return land
end

function update(o::NDWI_constant, forcing, land, infotem)
	# @unpack_NDWI_constant o
	return land
end

"""
sets the value of NDWI as a constant

# precompute:
precompute/instantiate time-invariant variables for NDWI_constant

# compute:
Normalized difference water index using NDWI_constant

*Inputs:*

*Outputs:*
 - land.states.NDWI: an extra forcing that creates a time series of constant NDWI

# update
update pools and states in NDWI_constant
 - land.states.NDWI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function NDWI_constant_h end