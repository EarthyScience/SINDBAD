export transpiration_none, transpiration_none_h
"""
sets the actual transpiration to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpiration_none{T} <: transpiration
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::transpiration_none, forcing, land, infotem)
	@unpack_transpiration_none o

	## calculate variables
	transpiration = 0.0

	## pack variables
	@pack_land begin
		transpiration ∋ land.fluxes
	end
	return land
end

function compute(o::transpiration_none, forcing, land, infotem)
	# @unpack_transpiration_none o
	return land
end

function update(o::transpiration_none, forcing, land, infotem)
	# @unpack_transpiration_none o
	return land
end

"""
sets the actual transpiration to zeros

# Extended help
"""
function transpiration_none_h end