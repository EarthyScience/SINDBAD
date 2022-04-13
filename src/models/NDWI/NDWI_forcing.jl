export NDWI_forcing, NDWI_forcing_h
"""
sets the value of land.states.NDWI from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct NDWI_forcing{T} <: NDWI
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::NDWI_forcing, forcing, land, infotem)
	# @unpack_NDWI_forcing o
	return land
end

function compute(o::NDWI_forcing, forcing, land, infotem)
	@unpack_NDWI_forcing o

	## unpack variables
	@unpack_land begin
		NDWI ∈ forcing
	end

	## pack variables
	@pack_land begin
		NDWI ∋ land.states
	end
	return land
end

function update(o::NDWI_forcing, forcing, land, infotem)
	# @unpack_NDWI_forcing o
	return land
end

"""
sets the value of land.states.NDWI from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for NDWI_forcing

# compute:
Normalized difference water index using NDWI_forcing

*Inputs:*
 - forcing.NDWI read from the forcing data set

*Outputs:*
 - land.states.NDWI: the value of NDWI for current time step

# update
update pools and states in NDWI_forcing
 - land.states.NDWI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 29.04.2020 [sbesnard]:  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function NDWI_forcing_h end