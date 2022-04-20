export groundWsurfaceWInteraction_fracWgw

@bounds @describe @units @with_kw struct groundWsurfaceWInteraction_fracWgw{T1} <: groundWsurfaceWInteraction
	kGW2Surf::T1 = 0.5 | (0.0001, 1.0) | "scale parameter for drainage from wGW to wSurf" | "fraction"
end

function compute(o::groundWsurfaceWInteraction_fracWgw, forcing, land, helpers)
	## unpack parameters
	@unpack_groundWsurfaceWInteraction_fracWgw o

	## unpack land variables
	@unpack_land (groundW, surfaceW) ∈ land.pools


	## calculate variables
	GW2Surf = kGW2Surf * groundW[1]

	## pack land variables
	@pack_land begin
		GW2Surf => land.fluxes
	end
	return land
end

function update(o::groundWsurfaceWInteraction_fracWgw, forcing, land, helpers)
	@unpack_groundWsurfaceWInteraction_fracWgw o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		GW2Surf ∈ land.fluxes
	end

	## update variables
	# update storages
	groundW[1] = groundW[1] - GW2Surf; 
	surfaceW[1] = surfaceW[1] + GW2Surf; 

	## pack land variables
	@pack_land (groundW, surfaceW) => land.pools
	return land
end

@doc """
calculates the depletion of groundwater to the surface water

# Parameters
$(PARAMFIELDS)

---

# compute:
Water exchange between surface and groundwater using groundWsurfaceWInteraction_fracWgw

*Inputs*
 - land.pools.groundW: groundwater storage
 - land.pools.surfaceW: surface water storage
 - land.runoffSurface.dc: drainage parameter from surfaceW[1]

*Outputs*
 - land.fluxes.groundW2surfaceW: groundW[1] to surfaceW[1] [always positive]

# update

update pools and states in groundWsurfaceWInteraction_fracWgw

 - land.pools.groundW[1]
 - land.pools.surfaceW[1]

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 04.02.2020 [ttraut]:  

*Created by:*
 - ttraut
"""
groundWsurfaceWInteraction_fracWgw