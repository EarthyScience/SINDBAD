export runoffSurface_directIndirectFroSoil

@bounds @describe @units @with_kw struct runoffSurface_directIndirectFroSoil{T1, T2} <: runoffSurface
	dc::T1 = 0.01 | (0.0, 1.0) | "delayed surface runoff coefficient" | ""
	rf::T2 = 0.5 | (0.0, 1.0) | "fraction of overland runoff that recharges the surface water storage" | ""
end

function compute(o::runoffSurface_directIndirectFroSoil, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_runoffSurface_directIndirectFroSoil o

	## unpack land variables
	@unpack_land begin
		fracFrozen ∈ land.runoffSaturationExcess
		surfaceW ∈ land.pools
		ΔsurfaceW ∈ land.states
		runoffOverland ∈ land.fluxes
		(𝟘, 𝟙) ∈ helpers.numbers
	end
	# fraction of overland runoff that flows out directly
	fracFastQ = (𝟙 - rf) * (𝟙 - fracFrozen) + fracFrozen

	runoffSurfaceDirect = fracFastQ * runoffOverland

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

function update(o::runoffSurface_directIndirectFroSoil, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_runoffSurface_directIndirectFroSoil o

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
		# surfaceW => land.pools
		ΔsurfaceW => land.states
	end
	return land
end

@doc """
assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid

# Parameters
$(PARAMFIELDS)

---

# compute:
Runoff from surface water storages using runoffSurface_directIndirectFroSoil

*Inputs*
 - land.fluxes.runoffOverland
 - land.runoffSaturationExcess.fracFrozen

*Outputs*

# update

update pools and states in runoffSurface_directIndirectFroSoil


---

# Extended help

*References*

*Versions*
 - 1.0 on 03.12.2020 [ttraut]  

*Created by:*
 - ttraut
"""
runoffSurface_directIndirectFroSoil