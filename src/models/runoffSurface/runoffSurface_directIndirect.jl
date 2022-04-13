export runoffSurface_directIndirect, runoffSurface_directIndirect_h
"""
calculate the runoff from surface water storage

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSurface_directIndirect{T1, T2} <: runoffSurface
	dc::T1 = 0.01 | (0.0001, 1.0) | "delayed surface runoff coefficient" | ""
	rf::T2 = 0.5 | (0.0001, 1.0) | "fraction of overland runoff that recharges the surface water storage" | ""
end

function precompute(o::runoffSurface_directIndirect, forcing, land, infotem)
	# @unpack_runoffSurface_directIndirect o
	return land
end

function compute(o::runoffSurface_directIndirect, forcing, land, infotem)
	@unpack_runoffSurface_directIndirect o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		runoffOverland ∈ land.fluxes
	end
	#--> fraction of overland runoff that recharges the surface water & the
	#fraction that flows out directly
	runoffSurfaceDirect = (1.0 - rf) * runoffOverland
	#--> fraction of surface storage that flows out irrespective of input
	surfaceWRec = rf * runoffOverland
	runoffSurfaceIndirect = dc * surfaceW[1]
	#--> get the total surface runoff
	runoffSurface = runoffSurfaceDirect + runoffSurfaceIndirect

	## pack variables
	@pack_land begin
		(runoffSurface, runoffSurfaceDirect, runoffSurfaceIndirect, surfaceWRec) ∋ land.fluxes
	end
	return land
end

function update(o::runoffSurface_directIndirect, forcing, land, infotem)
	@unpack_runoffSurface_directIndirect o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		(surfaceWRec, runoffSurfaceIndirect) ∈ land.fluxes
	end

	## update variables
	#--> update surface water storage
	surfaceW[1] = surfaceW[1] + surfaceWRec - runoffSurfaceIndirect; 

	## pack variables
	@pack_land begin
		surfaceW ∋ land.pools
	end
	return land
end

"""
calculate the runoff from surface water storage

# precompute:
precompute/instantiate time-invariant variables for runoffSurface_directIndirect

# compute:
Runoff from surface water storages using runoffSurface_directIndirect

*Inputs:*
 - land.fluxes.runoffOverland

*Outputs:*

# update
update pools and states in runoffSurface_directIndirect

# Extended help

*References:*
 -

*Versions:*

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoffSurface_directIndirect_h end