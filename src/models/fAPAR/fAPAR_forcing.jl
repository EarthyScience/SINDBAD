export fAPAR_forcing, fAPAR_forcing_h
"""
sets the value of land.states.fAPAR from the forcing in every time step

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct fAPAR_forcing{T} <: fAPAR
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::fAPAR_forcing, forcing, land, infotem)
	# @unpack_fAPAR_forcing o
	return land
end

function compute(o::fAPAR_forcing, forcing, land, infotem)
	@unpack_fAPAR_forcing o

	## unpack variables
	@unpack_land begin
		fAPAR ∈ forcing
	end

	## pack variables
	@pack_land begin
		fAPAR ∋ land.states
	end
	return land
end

function update(o::fAPAR_forcing, forcing, land, infotem)
	# @unpack_fAPAR_forcing o
	return land
end

"""
sets the value of land.states.fAPAR from the forcing in every time step

# precompute:
precompute/instantiate time-invariant variables for fAPAR_forcing

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_forcing

*Inputs:*
 - forcing.fAPAR read from the forcing data set
 - tix

*Outputs:*
 - land.states.fAPAR: the value of fAPAR for current time step

# update
update pools and states in fAPAR_forcing
 - land.states.fAPAR

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 23.11.2019 [skoirala]: new approach  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function fAPAR_forcing_h end