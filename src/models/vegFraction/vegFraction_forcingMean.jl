export vegFraction_forcingMean, vegFraction_forcingMean_h
"""
sets the value of land.states.vegFraction as the temporal mean from the forcing

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct vegFraction_forcingMean{T} <: vegFraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::vegFraction_forcingMean, forcing, land, infotem)
	# @unpack_vegFraction_forcingMean o
	return land
end

function compute(o::vegFraction_forcingMean, forcing, land, infotem)
	@unpack_vegFraction_forcingMean o

	## unpack variables
	@unpack_land begin
		vegFraction ∈ forcing
	end
	vegFraction = mean(vegFraction, 2)

	## pack variables
	@pack_land begin
		vegFraction ∋ land.states
	end
	return land
end

function update(o::vegFraction_forcingMean, forcing, land, infotem)
	# @unpack_vegFraction_forcingMean o
	return land
end

"""
sets the value of land.states.vegFraction as the temporal mean from the forcing

# precompute:
precompute/instantiate time-invariant variables for vegFraction_forcingMean

# compute:
Fractional coverage of vegetation using vegFraction_forcingMean

*Inputs:*
 - forcing.vegFraction read from the forcing data set
 - tix

*Outputs:*
 - land.states.vegFraction: the value of vegFraction for current time step

# update
update pools and states in vegFraction_forcingMean
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function vegFraction_forcingMean_h end