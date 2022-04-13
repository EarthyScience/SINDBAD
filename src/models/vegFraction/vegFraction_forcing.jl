export vegFraction_forcing, vegFraction_forcing_h
"""
sets the value of land.states.vegFraction from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_forcing{T} <: vegFraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::vegFraction_forcing, forcing, land, infotem)
	# @unpack_vegFraction_forcing o
	return land
end

function compute(o::vegFraction_forcing, forcing, land, infotem)
	@unpack_vegFraction_forcing o

	## unpack variables
	@unpack_land begin
		vegFraction ∈ forcing
	end

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_forcing, forcing, land, infotem)
	# @unpack_vegFraction_forcing o
	return land
end

"""
sets the value of land.states.vegFraction from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for vegFraction_forcing

# compute:
Fractional coverage of vegetation using vegFraction_forcing

*Inputs:*
 - forcing.vegFraction read from the forcing data set
 - tix

*Outputs:*
 - land.states.vegFraction: the value of vegFraction for current time step

# update
update pools and states in vegFraction_forcing
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function vegFraction_forcing_h end