export runoffBase_none, runoffBase_none_h
"""
sets the base runoff to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffBase_none{T} <: runoffBase
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffBase_none, forcing, land, infotem)
	@unpack_runoffBase_none o

	## calculate variables
	runoffBase = 0.0

	## pack variables
	@pack_land begin
		runoffBase ∋ land.fluxes
	end
	return land
end

function compute(o::runoffBase_none, forcing, land, infotem)
	# @unpack_runoffBase_none o
	return land
end

function update(o::runoffBase_none, forcing, land, infotem)
	# @unpack_runoffBase_none o
	return land
end

"""
sets the base runoff to zeros

# Extended help
"""
function runoffBase_none_h end