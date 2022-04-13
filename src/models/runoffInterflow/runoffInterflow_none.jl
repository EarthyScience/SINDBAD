export runoffInterflow_none, runoffInterflow_none_h
"""
sets interflow runoff to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffInterflow_none{T} <: runoffInterflow
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffInterflow_none, forcing, land, infotem)
	@unpack_runoffInterflow_none o

	## calculate variables
	roInt = 0.0

	## pack variables
	@pack_land begin
		roInt ∋ land.fluxes
	end
	return land
end

function compute(o::runoffInterflow_none, forcing, land, infotem)
	# @unpack_runoffInterflow_none o
	return land
end

function update(o::runoffInterflow_none, forcing, land, infotem)
	# @unpack_runoffInterflow_none o
	return land
end

"""
sets interflow runoff to zeros

# Extended help
"""
function runoffInterflow_none_h end