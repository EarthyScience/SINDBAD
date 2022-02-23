export groundWsurfaceWInteraction_fracWgw

@bounds @describe @units @with_kw struct groundWsurfaceWInteraction_fracWgw{T1} <: groundWsurfaceWInteraction
	kGW2Surf::T1 = 0.5 | (0.0001, 0.999) | "scale parameter for drainage from wGW to wSurf" | "fraction"
end

function compute(o::groundWsurfaceWInteraction_fracWgw, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_groundWsurfaceWInteraction_fracWgw o

	## unpack land variables
	@unpack_land begin
		(groundW, surfaceW) ∈ land.pools
		(ΔsurfaceW, ΔgroundW) ∈ land.states
	end

	## calculate variables
	GW2Surf = kGW2Surf * sum(groundW + ΔgroundW)

	# update the delta storages
	ΔgroundW .= ΔgroundW .- GW2Surf / length(groundW)
	ΔsurfaceW .= ΔsurfaceW .+ GW2Surf / length(surfaceW)

	## pack land variables
	@pack_land begin
		GW2Surf => land.fluxes
		(ΔsurfaceW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWsurfaceWInteraction_fracWgw, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack variables
	@unpack_land begin
		(groundW, surfaceW) ∈ land.pools
		(ΔgroundW, ΔsurfaceW) ∈ land.states
	end

	## update storage pools
	surfaceW .= surfaceW .+ ΔsurfaceW
	groundW .= groundW .+ ΔgroundW

	# reset ΔgroundW and ΔsurfaceW to zero
	ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW
	ΔgroundW .= ΔgroundW .- ΔgroundW


	## pack land variables
	@pack_land begin
		(groundW, surfaceW) => land.pools
		(ΔgroundW, ΔsurfaceW) => land.states
	end
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
 - land.runoffSurface.dc: drainage parameter from surfaceW

*Outputs*
 - land.fluxes.groundW2surfaceW: groundW to surfaceW [always positive]

# update

update pools and states in groundWsurfaceWInteraction_fracWgw

 - land.pools.groundW
 - land.pools.surfaceW

---

# Extended help

*References*

*Versions*
 - 1.0 on 04.02.2020 [ttraut]

*Created by:*
 - ttraut
"""
groundWsurfaceWInteraction_fracWgw