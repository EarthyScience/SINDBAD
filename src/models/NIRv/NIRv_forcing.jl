export NIRv_forcing

struct NIRv_forcing <: NIRv
end

function compute(o::NIRv_forcing, forcing, land, helpers)
	## unpack forcing
	@unpack_forcing NIRv ∈ forcing

	## pack land variables
	@pack_land NIRv => land.states
	return land
end

@doc """
sets the value of land.states.NIRv from the forcing in every time step

---

# compute:
Near-infrared reflectance of terrestrial vegetation using NIRv_forcing

*Inputs*
 - forcing.NIRv read from the forcing data set

*Outputs*
 - land.states.NIRv: the value of NIRv for current time step
 - land.states.NIRv

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]

*Created by:*
 - sbesnard
"""
NIRv_forcing