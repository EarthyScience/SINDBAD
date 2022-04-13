export ambientCO2_forcing, ambientCO2_forcing_h
"""
sets the value of land.states.ambCO2 from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct ambientCO2_forcing{T} <: ambientCO2
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::ambientCO2_forcing, forcing, land, infotem)
	# @unpack_ambientCO2_forcing o
	return land
end

function compute(o::ambientCO2_forcing, forcing, land, infotem)
	@unpack_ambientCO2_forcing o

	## unpack variables
	@unpack_land begin
		ambCO2 ∈ forcing
	end

	## pack variables
	@pack_land begin
		ambCO2 ∋ land.states
	end
	return land
end

function update(o::ambientCO2_forcing, forcing, land, infotem)
	# @unpack_ambientCO2_forcing o
	return land
end

"""
sets the value of land.states.ambCO2 from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for ambientCO2_forcing

# compute:
Set/get ambient co2 concentration using ambientCO2_forcing

*Inputs:*
 - forcing.ambCO2 read from the forcing data set

*Outputs:*
 - land.states.ambCO2: the value of LAI for current time step

# update
update pools and states in ambientCO2_forcing
 - land.states.ambCO2

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function ambientCO2_forcing_h end