export getPools_simple, getPools_simple_h
"""
gets the amount of water available for the current time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct getPools_simple{T} <: getPools
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::getPools_simple, forcing, land, infotem)
	# @unpack_getPools_simple o
	return land
end

function compute(o::getPools_simple, forcing, land, infotem)
	@unpack_getPools_simple o

	## unpack variables
	@unpack_land begin
		rain ∈ land.rainSnow
	end
	WBP = rain

	## pack variables
	@pack_land begin
		WBP ∋ land.states
	end
	return land
end

function update(o::getPools_simple, forcing, land, infotem)
	# @unpack_getPools_simple o
	return land
end

"""
gets the amount of water available for the current time step

# precompute:
precompute/instantiate time-invariant variables for getPools_simple

# compute:
Get the amount of water at the beginning of timestep using getPools_simple

*Inputs:*
 - amount of rainfall
 - tix

*Outputs:*
 - land.states.WBP: the amount of liquid water input to the system

# update
update pools and states in getPools_simple
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 19.11.2019 [skoirala]: added the documentation & cleaned the code, added json with development stage

*Created by:*
 - Martin Jung [mjung]
 - Nuno Carvalhais [ncarval]
 - Sujan Koirala [skoirala]
"""
function getPools_simple_h end