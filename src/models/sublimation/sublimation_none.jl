export sublimation_none, sublimation_none_h
"""
sets the snow sublimation to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct sublimation_none{T} <: sublimation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::sublimation_none, forcing, land, infotem)
	@unpack_sublimation_none o

	## calculate variables
	sublimation = info.tem.helpers.arrays.zerospixtix

	## pack variables
	@pack_land begin
		sublimation ∋ land.fluxes
	end
	return land
end

function compute(o::sublimation_none, forcing, land, infotem)
	# @unpack_sublimation_none o
	return land
end

function update(o::sublimation_none, forcing, land, infotem)
	# @unpack_sublimation_none o
	return land
end

"""
sets the snow sublimation to zeros

# Extended help
"""
function sublimation_none_h end