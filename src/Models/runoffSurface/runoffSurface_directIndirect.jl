export runoffSurface_directIndirect

@bounds @describe @units @with_kw struct runoffSurface_directIndirect{T1, T2} <: runoffSurface
	dc::T1 = 0.01 | (0.0001, 1.0) | "delayed surface runoff coefficient" | ""
	rf::T2 = 0.5 | (0.0001, 1.0) | "fraction of overland runoff that recharges the surface water storage" | ""
end

function compute(o::runoffSurface_directIndirect, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffSurface_directIndirect o

	## unpack land variables
	@unpack_land begin
		surfaceW ∈ land.pools
		ΔsurfaceW ∈ land.states
		runoffOverland ∈ land.fluxes
		(𝟘, 𝟙) ∈ helpers.numbers
	end
	# fraction of overland runoff that recharges the surface water & the
	#fraction that flows out directly
	runoffSurfaceDirect = (𝟙 - rf) * runoffOverland

	# fraction of surface storage that flows out irrespective of input
	surfaceWRec = rf * runoffOverland
	runoffSurfaceIndirect = dc * sum(surfaceW + ΔsurfaceW)

	# get the total surface runoff
	runoffSurface = runoffSurfaceDirect + runoffSurfaceIndirect

	# update the delta storage
	ΔsurfaceW[1] = ΔsurfaceW[1] + surfaceWRec # assumes all the recharge supplies the first surface water layer
	ΔsurfaceW .= ΔsurfaceW .- runoffSurfaceIndirect / length(surfaceW) # assumes all layers contribute equally to indirect component of surface runoff

	## pack land variables
	@pack_land begin
		(runoffSurface, runoffSurfaceDirect, runoffSurfaceIndirect, surfaceWRec) => land.fluxes
		ΔsurfaceW => land.states
	end
	return land
end

function update(o::runoffSurface_directIndirect, forcing, land, helpers)
	@unpack_runoffSurface_directIndirect o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		ΔsurfaceW ∈ land.states
	end

	## update storage pools
	surfaceW .= surfaceW .+ ΔsurfaceW

	# reset ΔsurfaceW to zero
	ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

	## pack land variables
	@pack_land begin
		surfaceW => land.pools
		ΔsurfaceW => land.states
	end
	return land
end

@doc """
assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage

# Parameters
$(PARAMFIELDS)

---

# compute:
Runoff from surface water storages using runoffSurface_directIndirect

*Inputs*
 - land.fluxes.runoffOverland

*Outputs*

# update

update pools and states in runoffSurface_directIndirect


---

# Extended help

*References*

*Versions*

*Created by:*
 - skoirala
"""
runoffSurface_directIndirect