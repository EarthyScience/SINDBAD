export treeFraction_forcing, treeFraction_forcing_h
"""
sets the value of land.states.treeFraction from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct treeFraction_forcing{T} <: treeFraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::treeFraction_forcing, forcing, land, infotem)
	# @unpack_treeFraction_forcing o
	return land
end

function compute(o::treeFraction_forcing, forcing, land, infotem)
	@unpack_treeFraction_forcing o

	## unpack variables
	@unpack_land begin
		treeFraction ∈ forcing
	end

	## pack variables
	@pack_land begin
		treeFraction ∋ land.states
	end
	return land
end

function update(o::treeFraction_forcing, forcing, land, infotem)
	# @unpack_treeFraction_forcing o
	return land
end

"""
sets the value of land.states.treeFraction from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for treeFraction_forcing

# compute:
Fractional coverage of trees using treeFraction_forcing

*Inputs:*
 - forcing.treeFraction read from the forcing data set
 - tix

*Outputs:*
 - land.states.treeFraction: the value of treeFraction for current time step

# update
update pools and states in treeFraction_forcing
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function treeFraction_forcing_h end