export groundWsurfaceWInteraction_fracGradient

@bounds @describe @units @with_kw struct groundWsurfaceWInteraction_fracGradient{T1} <: groundWsurfaceWInteraction
	kGW2Surf::T1 = 0.001 | (0.0001, 0.01) | "maximum transfer rate between GW and surface water" | "/d"
end

function compute(o::groundWsurfaceWInteraction_fracGradient, forcing, land, helpers)
	## unpack parameters
	@unpack_groundWsurfaceWInteraction_fracGradient o

	## unpack land variables
	@unpack_land begin
		(groundW, surfaceW) ∈ land.pools
		(ΔsurfaceW, ΔgroundW) ∈ land.states
	end

	## calculate variables
	tmp = kGW2Surf * (sum(groundW + ΔgroundW) - sum(surfaceW + ΔsurfaceW))


	# update the delta storages
	ΔgroundW = ΔgroundW .- GW2Surf / length(groundW)
	ΔsurfaceW = ΔsurfaceW .+ GW2Surf / length(groundW)

	## pack land variables
	@pack_land begin
		GW2Surf => land.fluxes
		(ΔsurfaceW, ΔgroundW) => land.states
	end

	return land
end

function update(o::groundWsurfaceWInteraction_fracGradient, forcing, land, helpers)
	## unpack variables
	@unpack_land begin
		(groundW, surfaceW) ∈ land.pools
		(ΔgroundW, ΔsurfaceW) ∈ land.states
	end

	## update storage pools
	surfaceW = surfaceW + ΔsurfaceW
	groundW = groundW + ΔgroundW

	# reset ΔgroundW and ΔsurfaceW to zero
	ΔsurfaceW = ΔsurfaceW - ΔsurfaceW
	ΔgroundW = ΔgroundW - ΔgroundW


	## pack land variables
	@pack_land begin
		(groundW, surfaceW) => land.pools
		(ΔgroundW, ΔsurfaceW) => land.states
	end
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
 - negative: surfaceW to groundW
 - positive: groundW to surfaceW

# update

update pools and states in groundWsurfaceWInteraction_fracGradient

 - land.pools.groundW
 - land.pools.surfaceW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
groundWsurfaceWInteraction_fracGradient