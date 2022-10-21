export runoffSurface_indirect

@bounds @describe @units @with_kw struct runoffSurface_indirect{T1} <: runoffSurface
	dc::T1 = 0.01 | (0.0, 1.0) | "delayed surface runoff coefficient" | ""
end

function compute(o::runoffSurface_indirect, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_runoffSurface_indirect o

	## unpack land variables
	@unpack_land begin
		surfaceW ∈ land.pools
		runoffOverland ∈ land.fluxes
	end

	# fraction of overland runoff that recharges the surface water & the fraction that flows out directly
	surfaceWRec = runoffOverland

	# fraction of surface storage that flows out as surface runoff
	runoffSurface = dc * sum(surfaceW)

	# update the delta storage
	ΔsurfaceW[1] = ΔsurfaceW[1] + surfaceWRec # assumes all the recharge supplies the first surface water layer
	ΔsurfaceW .= ΔsurfaceW .- runoffSurface / length(surfaceW) # assumes all layers contribute equally to indirect component of surface runoff

	## pack land variables
	@pack_land begin
		(runoffSurface, surfaceWRec) => land.fluxes
		ΔsurfaceW => land.states
	end
	return land
end

function update(o::runoffSurface_indirect, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_runoffSurface_indirect o

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
assumes all overland runoff is recharged to surface water first, which then generates surface runoff

# Parameters
$(PARAMFIELDS)

---

# compute:
Runoff from surface water storages using runoffSurface_indirect

*Inputs*
 - land.fluxes.runoffOverland
 - land.states.surfaceW[1]

*Outputs*
 - land.fluxes.runoffSurface & its indirect/slow component

# update

update pools and states in runoffSurface_indirect

 - land.pools.surfaceW[1]

---

# Extended help

*References*

*Versions*
 - 1.0 on 20.11.2019 [skoirala]: combine runoffSurfaceDirect, Indir, surfaceWRec  

*Created by:*
 - skoirala
"""
runoffSurface_indirect