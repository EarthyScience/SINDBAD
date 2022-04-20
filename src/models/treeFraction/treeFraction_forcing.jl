export treeFraction_forcing

struct treeFraction_forcing <: treeFraction
end

function compute(o::treeFraction_forcing, forcing, land, infotem)
	## unpack forcing
	@unpack_forcing treeFraction ∈ forcing

	## pack land variables
	@pack_land treeFraction => land.states
	return land
end

@doc """
sets the value of land.states.treeFraction from the forcing in every time step

---

# compute:
Fractional coverage of trees using treeFraction_forcing

*Inputs*
 - forcing.treeFraction read from the forcing data set

*Outputs*
 - land.states.treeFraction: the value of treeFraction for current time step

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
treeFraction_forcing