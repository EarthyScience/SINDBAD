export groundWsurfaceWInteraction_fracGradient

@bounds @describe @units @with_kw struct groundWsurfaceWInteraction_fracGradient{T1} <: groundWsurfaceWInteraction
	kGW2Surf::T1 = 0.001 | (0.0001, 0.01) | "maximum transfer rate between GW and surface water" | "/d"
end

function compute(o::groundWsurfaceWInteraction_fracGradient, forcing, land, helpers)
	## unpack parameters
	@unpack_groundWsurfaceWInteraction_fracGradient o

	## unpack land variables
	@unpack_land (groundW, surfaceW) ∈ land.pools


	## calculate variables
	groundW2surfaceW = kGW2Surf * (groundW[1] - surfaceW[1])

	## pack land variables
	@pack_land begin
		groundW2surfaceW => land.fluxes
	end
	return land
end

function update(o::groundWsurfaceWInteraction_fracGradient, forcing, land, helpers)
	@unpack_groundWsurfaceWInteraction_fracGradient o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		groundW2surfaceW ∈ land.fluxes
	end

	## update variables
	# update storages
	groundW[1] = groundW[1] - groundW2surfaceW; 
	surfaceW[1] = surfaceW[1] + groundW2surfaceW; 

	## pack land variables
	@pack_land (groundW, surfaceW) => land.pools
	return land
end

@doc """
calculates the moisture exchange between groundwater & surface water as a fraction of difference between the storages

# Parameters
$(PARAMFIELDS)

---

# compute:
Water exchange between surface and groundwater using groundWsurfaceWInteraction_fracGradient

*Inputs*
 - land.pools.groundW: groundwater storage
 - land.pools.surfaceW: surface water storage

*Outputs*
 - land.fluxes.groundW2surfaceW:
 - negative: surfaceW[1] to groundW[1]
 - positive: groundW[1] to surfaceW[1]

# update

update pools and states in groundWsurfaceWInteraction_fracGradient

 - land.pools.groundW[1]
 - land.pools.surfaceW[1]

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
groundWsurfaceWInteraction_fracGradient