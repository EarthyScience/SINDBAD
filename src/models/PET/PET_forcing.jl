export PET_forcing, PET_forcing_h
"""
sets the value of land.PET.PET from the forcing

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct PET_forcing{T} <: PET
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::PET_forcing, forcing, land, infotem)
	# @unpack_PET_forcing o
	return land
end

function compute(o::PET_forcing, forcing, land, infotem)
	@unpack_PET_forcing o

	## unpack variables
	@unpack_land begin
		PET ∈ forcing
	end

	## pack variables
	@pack_land begin
		PET ∋ land.PET
	end
	return land
end

function update(o::PET_forcing, forcing, land, infotem)
	# @unpack_PET_forcing o
	return land
end

"""
sets the value of land.PET.PET from the forcing

# precompute:
precompute/instantiate time-invariant variables for PET_forcing

# compute:
Set potential evapotranspiration using PET_forcing

*Inputs:*
 - forcing.PET read from the forcing data set

*Outputs:*
 - land.PET.PET: the value of PET for current time step

# update
update pools and states in PET_forcing
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function PET_forcing_h end