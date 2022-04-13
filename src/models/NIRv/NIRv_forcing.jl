export NIRv_forcing, NIRv_forcing_h
"""
sets the value of land.states.NIRv from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct NIRv_forcing{T} <: NIRv
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::NIRv_forcing, forcing, land, infotem)
	# @unpack_NIRv_forcing o
	return land
end

function compute(o::NIRv_forcing, forcing, land, infotem)
	@unpack_NIRv_forcing o

	## unpack variables
	@unpack_land begin
		NIRv ∈ forcing
	end

	## pack variables
	@pack_land begin
		NIRv ∋ land.states
	end
	return land
end

function update(o::NIRv_forcing, forcing, land, infotem)
	# @unpack_NIRv_forcing o
	return land
end

"""
sets the value of land.states.NIRv from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for NIRv_forcing

# compute:
Near-infrared reflectance of terrestrial vegetation using NIRv_forcing

*Inputs:*
 - forcing.NIRv read from the forcing data set

*Outputs:*
 - land.states.NIRv: the value of NIRv for current time step

# update
update pools and states in NIRv_forcing
 - land.states.NIRv

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 29.04.2020 [sbesnard]:  

*Created by:*
 - Simon Besnard [sbesnard]
"""
function NIRv_forcing_h end