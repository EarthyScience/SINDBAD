export LAI_forcing

struct LAI_forcing <: LAI
end

function compute(o::LAI_forcing, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack forcing
	@unpack_forcing LAI ∈ forcing

	## pack land variables
	@pack_land LAI => land.states
	return land
end

@doc """
sets the value of land.states.LAI from the forcing in every time step

---

# compute:
Leaf area index using LAI_forcing

*Inputs*
 - forcing.LAI read from the forcing data set

*Outputs*
 - land.states.LAI: the value of LAI for current time step
 - land.states.LAI

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: moved LAI from land.LAI.LAI to land.states.LAI  

*Created by:*
 - skoirala
"""
LAI_forcing