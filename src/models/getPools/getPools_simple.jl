export getPools_simple

struct getPools_simple <: getPools
end

function precompute(o::getPools_simple, forcing, land, helpers)
	@unpack_land numType ∈ helpers.numbers
	## instantiate water pool changes
	# ΔsoilW = zeros(numType, length(land.pools.soilW))
	# ΔgroundW = zeros(numType, length(land.pools.groundW))
	# ΔsurfaceW = zeros(numType, length(land.pools.surfaceW))
	# ΔsnowW = zeros(numType, length(land.pools.snowW))

	# ## pack land variables
	# @pack_land (ΔsoilW, ΔgroundW, ΔsurfaceW, ΔsnowW) => land.states
	return land
end

function compute(o::getPools_simple, forcing, land, helpers)

	## unpack land variables
	@unpack_land rain ∈ land.rainSnow


	## calculate variables
	WBP = rain

	## pack land variables
	@pack_land WBP => land.states
	return land
end

@doc """
gets the amount of water available for the current time step

---

# compute:
Get the amount of water at the beginning of timestep using getPools_simple

*Inputs*
 - amount of rainfall

*Outputs*
 - land.states.WBP: the amount of liquid water input to the system

---

# Extended help

*References*

*Versions*
 - 1.0 on 19.11.2019 [skoirala]: added the documentation & cleaned the code, added json with development stage

*Created by:*
 - mjung
 - ncarval
 - skoirala
"""
getPools_simple