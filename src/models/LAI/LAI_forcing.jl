export LAI_forcing, LAI_forcing_h
"""
sets the value of land.states.LAI from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct LAI_forcing{T} <: LAI
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::LAI_forcing, forcing, land, infotem)
	# @unpack_LAI_forcing o
	return land
end

function compute(o::LAI_forcing, forcing, land, infotem)
	@unpack_LAI_forcing o

	## unpack variables
	@unpack_land begin
		LAI ∈ forcing
	end

	## pack variables
	@pack_land begin
		LAI ∋ land.states
	end
	return land
end

function update(o::LAI_forcing, forcing, land, infotem)
	# @unpack_LAI_forcing o
	return land
end

"""
sets the value of land.states.LAI from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for LAI_forcing

# compute:
Leaf area index using LAI_forcing

*Inputs:*
 - forcing.LAI read from the forcing data set

*Outputs:*
 - land.states.LAI: the value of LAI for current time step

# update
update pools and states in LAI_forcing
 - land.states.LAI

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: moved LAI from land.LAI.LAI to land.states.LAI  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function LAI_forcing_h end