export vegFraction_forcing

struct vegFraction_forcing <: vegFraction
end

function compute(o::vegFraction_forcing, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_forcing vegFraction ∈ forcing

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of land.states.vegFraction from the forcing in every time step

---

# compute:
Fractional coverage of vegetation using vegFraction_forcing

*Inputs*
 - forcing.vegFraction read from the forcing data set

*Outputs*
 - land.states.vegFraction: the value of vegFraction for current time step

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
vegFraction_forcing