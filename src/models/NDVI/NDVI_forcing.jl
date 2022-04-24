export NDVI_forcing

struct NDVI_forcing <: NDVI
end

function compute(o::NDVI_forcing, forcing, land, helpers)
	## unpack forcing
	@unpack_forcing NDVI ∈ forcing

	## pack land variables
	@pack_land NDVI => land.states
	return land
end

@doc """
sets the value of land.states.NDVI from the forcing in every time step

---

# compute:
Normalized difference vegetation index using NDVI_forcing

*Inputs*
 - forcing.NDVI read from the forcing data set

*Outputs*
 - land.states.NDVI: the value of NDVI for current time step
 - land.states.NDVI

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]

*Created by:*
 - sbesnard
"""
NDVI_forcing