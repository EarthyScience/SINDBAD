export runoffSurface_directIndirectFroSoil

@bounds @describe @units @with_kw struct runoffSurface_directIndirectFroSoil{T1, T2} <: runoffSurface
	dc::T1 = 0.01 | (0.0, 1.0) | "delayed surface runoff coefficient" | ""
	rf::T2 = 0.5 | (0.0, 1.0) | "fraction of overland runoff that recharges the surface water storage" | ""
end

function compute(o::runoffSurface_directIndirectFroSoil, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffSurface_directIndirectFroSoil o

	## unpack land variables
	@unpack_land begin
		fracFrozen ∈ land.runoffSaturationExcess
		surfaceW ∈ land.pools
		runoffOverland ∈ land.fluxes
	end
	# fraction of overland runoff that recharges the surface water & the
	#fraction that flows out directly
	fracFastQ = (1.0 - rf) * (1.0 - fracFrozen) + fracFrozen
	runoffSurfaceDirect = fracFastQ * runoffOverland
	# fraction of surface storage that flows out irrespective of input
	surfaceWRec = (1.0 - fracFastQ) * runoffOverland
	runoffSurfaceIndirect = dc * surfaceW[1]
	# get the total surface runoff
	runoffSurface = runoffSurfaceDirect + runoffSurfaceIndirect

	## pack land variables
	@pack_land begin
		(runoffSurface, runoffSurfaceDirect, runoffSurfaceIndirect, surfaceWRec) => land.fluxes
		fracFastQ => land.runoffSurface
	end
	return land
end

function update(o::runoffSurface_directIndirectFroSoil, forcing, land, helpers)
	@unpack_runoffSurface_directIndirectFroSoil o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		(surfaceWRec, runoffSurfaceIndirect) ∈ land.fluxes
	end

	## update variables
	# update surface water storage
	surfaceW[1] = surfaceW[1] + surfaceWRec - runoffSurfaceIndirect

	## pack land variables
	@pack_land surfaceW => land.pools
	return land
end

@doc """
calculate the runoff from surface water storage considering frozen soil fraction

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
 -

*Versions*
 - 1.0 on 03.12.2020 [ttraut]  

*Created by:*
 - ttraut
"""
runoffSurface_directIndirectFroSoil