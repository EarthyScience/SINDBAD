export runoffSurface_none, runoffSurface_none_h
"""
sets surface runoff [runoffSurface] from the storage to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSurface_none{T} <: runoffSurface
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffSurface_none, forcing, land, infotem)
	@unpack_runoffSurface_none o

	## calculate variables
	runoffSurface = 0.0

	## pack variables
	@pack_land begin
		runoffSurface ∋ land.fluxes
	end
	return land
end

function compute(o::runoffSurface_none, forcing, land, infotem)
	# @unpack_runoffSurface_none o
	return land
end

function update(o::runoffSurface_none, forcing, land, infotem)
	# @unpack_runoffSurface_none o
	return land
end

"""
sets surface runoff [runoffSurface] from the storage to zeros

# Extended help
"""
function runoffSurface_none_h end