export fAPAR_forcing

struct fAPAR_forcing <: fAPAR
end

function compute(o::fAPAR_forcing, forcing, land, helpers)
	## unpack forcing
	@unpack_forcing fAPAR ∈ forcing

	## pack land variables
	@pack_land fAPAR => land.states
	return land
end

@doc """
sets the value of land.states.fAPAR from the forcing in every time step

---

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_forcing

*Inputs*
 - forcing.fAPAR read from the forcing data set

*Outputs*
 - land.states.fAPAR: the value of fAPAR for current time step
 - land.states.fAPAR

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 23.11.2019 [skoirala]: new approach  

*Created by:*
 - skoirala
"""
fAPAR_forcing