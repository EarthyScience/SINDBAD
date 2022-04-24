export ambientCO2_forcing

struct ambientCO2_forcing <: ambientCO2
end

function compute(o::ambientCO2_forcing, forcing, land, helpers)
	## unpack forcing
	@unpack_forcing ambCO2 ∈ forcing

	## pack land variables
	@pack_land ambCO2 => land.states
	return land
end

@doc """
sets the value of land.states.ambCO2 from the forcing in every time step

---

# compute:
Set/get ambient co2 concentration using ambientCO2_forcing

*Inputs*
 - forcing.ambCO2 read from the forcing data set

*Outputs*
 - land.states.ambCO2: the value of LAI for current time step
 - land.states.ambCO2

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
ambientCO2_forcing