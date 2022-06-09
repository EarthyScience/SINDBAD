export runoffSurface_all

struct runoffSurface_all <: runoffSurface
end

function compute(o::runoffSurface_all, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land runoffOverland ∈ land.fluxes


	## calculate variables
	# all overland flow becomes surface runoff
	runoffSurface = runoffOverland

	## pack land variables
	@pack_land runoffSurface => land.fluxes
	return land
end

@doc """
assumes all overland runoff is lost as surface runoff

---

# compute:
Runoff from surface water storages using runoffSurface_all

*Inputs*
 - land.fluxes.runoffOverland
 - land.states.surfaceW[1]

*Outputs*
 - land.fluxes.runoffSurface
 - land.pools.surfaceW[1]

---

# Extended help

*References*

*Versions*
 - 1.0 on 20.11.2019 [skoirala]: combine runoffSurfaceDirect, Indir, surfaceWRec  

*Created by:*
 - skoirala
"""
runoffSurface_all