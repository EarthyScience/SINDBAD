export runoffOverland_none, runoffOverland_none_h
"""
sets overland runoff to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffOverland_none{T} <: runoffOverland
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffOverland_none, forcing, land, infotem)
	@unpack_runoffOverland_none o

	## calculate variables
	runoffOverland = 0.0

	## pack variables
	@pack_land begin
		runoffOverland ∋ land.fluxes
	end
	return land
end

function compute(o::runoffOverland_none, forcing, land, infotem)
	# @unpack_runoffOverland_none o
	return land
end

function update(o::runoffOverland_none, forcing, land, infotem)
	# @unpack_runoffOverland_none o
	return land
end

"""
sets overland runoff to zeros

# Extended help
"""
function runoffOverland_none_h end