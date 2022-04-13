export EVI_forcing, EVI_forcing_h
"""
sets the value of land.states.EVI from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct EVI_forcing{T} <: EVI
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::EVI_forcing, forcing, land, infotem)
	# @unpack_EVI_forcing o
	return land
end

function compute(o::EVI_forcing, forcing, land, infotem)
	@unpack_EVI_forcing o

	## unpack variables
	@unpack_land begin
		EVI ∈ forcing
	end

	## pack variables
	@pack_land begin
		EVI ∋ land.states
	end
	return land
end

function update(o::EVI_forcing, forcing, land, infotem)
	# @unpack_EVI_forcing o
	return land
end

"""
sets the value of land.states.EVI from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for EVI_forcing

# compute:
Enhanced vegetation index using EVI_forcing

*Inputs:*
 - forcing.EVI read from the forcing data set

*Outputs:*
 - land.states.EVI: the value of EVI for current time step

# update
update pools and states in EVI_forcing
 - land.states.EVI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function EVI_forcing_h end