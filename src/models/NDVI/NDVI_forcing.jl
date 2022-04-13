export NDVI_forcing, NDVI_forcing_h
"""
sets the value of land.states.NDVI from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct NDVI_forcing{T} <: NDVI
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::NDVI_forcing, forcing, land, infotem)
	# @unpack_NDVI_forcing o
	return land
end

function compute(o::NDVI_forcing, forcing, land, infotem)
	@unpack_NDVI_forcing o

	## unpack variables
	@unpack_land begin
		NDVI ∈ forcing
	end

	## pack variables
	@pack_land begin
		NDVI ∋ land.states
	end
	return land
end

function update(o::NDVI_forcing, forcing, land, infotem)
	# @unpack_NDVI_forcing o
	return land
end

"""
sets the value of land.states.NDVI from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for NDVI_forcing

# compute:
Normalized difference vegetation index using NDVI_forcing

*Inputs:*
 - forcing.NDVI read from the forcing data set

*Outputs:*
 - land.states.NDVI: the value of NDVI for current time step

# update
update pools and states in NDVI_forcing
 - land.states.NDVI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 29.04.2020 [sbesnard]:  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function NDVI_forcing_h end