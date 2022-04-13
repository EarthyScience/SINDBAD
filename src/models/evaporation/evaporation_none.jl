export evaporation_none, evaporation_none_h
"""
sets the soil evaporation to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evaporation_none{T} <: evaporation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::evaporation_none, forcing, land, infotem)
	@unpack_evaporation_none o

	## calculate variables
	evaporation = 0.0

	## pack variables
	@pack_land begin
		evaporation ∋ land.fluxes
	end
	return land
end

function compute(o::evaporation_none, forcing, land, infotem)
	# @unpack_evaporation_none o
	return land
end

function update(o::evaporation_none, forcing, land, infotem)
	# @unpack_evaporation_none o
	return land
end

"""
sets the soil evaporation to zeros

# Extended help
"""
function evaporation_none_h end