export runoffSurface_all, runoffSurface_all_h
"""
calculate the runoff from surface water storage

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSurface_all{T} <: runoffSurface
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffSurface_all, forcing, land, infotem)
	# @unpack_runoffSurface_all o
	return land
end

function compute(o::runoffSurface_all, forcing, land, infotem)
	@unpack_runoffSurface_all o

	## unpack variables
	@unpack_land begin
		runoffOverland ∈ land.fluxes
	end
	#--> all overland flow becomes surface runoff
	runoffSurface = runoffOverland

	## pack variables
	@pack_land begin
		runoffSurface ∋ land.fluxes
	end
	return land
end

function update(o::runoffSurface_all, forcing, land, infotem)
	# @unpack_runoffSurface_all o
	return land
end

"""
calculate the runoff from surface water storage

# precompute:
precompute/instantiate time-invariant variables for runoffSurface_all

# compute:
Runoff from surface water storages using runoffSurface_all

*Inputs:*
 - land.fluxes.runoffOverland
 - land.states.surfaceW[1]

*Outputs:*
 - land.fluxes.runoffSurface

# update
update pools and states in runoffSurface_all
 - land.pools.surfaceW[1]

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 20.11.2019 [skoirala]: combine runoffSurfaceDirect, Indir, surfaceWRec  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoffSurface_all_h end