export evapotranspiration_sum, evapotranspiration_sum_h
"""
calculates evapotranspiration as a sum of all potential components

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evapotranspiration_sum{T} <: evapotranspiration
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::evapotranspiration_sum, forcing, land, infotem)
	# @unpack_evapotranspiration_sum o
	return land
end

function compute(o::evapotranspiration_sum, forcing, land, infotem)
	@unpack_evapotranspiration_sum o

	## unpack variables
	@unpack_land begin
		(evaporation, interception, sublimation, transpiration) ∈ land.fluxes
	end
	evapotranspiration = interception + transpiration + evaporation + sublimation

	## pack variables
	@pack_land begin
		evapotranspiration ∋ land.fluxes
	end
	return land
end

function update(o::evapotranspiration_sum, forcing, land, infotem)
	# @unpack_evapotranspiration_sum o
	return land
end

"""
calculates evapotranspiration as a sum of all potential components

# precompute:
precompute/instantiate time-invariant variables for evapotranspiration_sum

# compute:
Calculate the evapotranspiration as a sum of components using evapotranspiration_sum

*Inputs:*
 - land.fluxes.evaporation
 - land.fluxes.interception
 - land.fluxes.sublimation
 - land.fluxes.transpiration

*Outputs:*
 - land.fluxes.evapotranspiration

# update
update pools and states in evapotranspiration_sum
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 01.04.2022  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function evapotranspiration_sum_h end