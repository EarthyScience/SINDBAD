export treeFraction_constant

@bounds @describe @units @with_kw struct treeFraction_constant{T1} <: treeFraction
	constantTreeFrac::T1 = 1.0 | (0.3, 1.0) | "Tree fraction" | ""
end

function compute(o::treeFraction_constant, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_treeFraction_constant o

	## calculate variables
	treeFraction = constantTreeFrac

	## pack land variables
	@pack_land treeFraction => land.states
	return land
end

@doc """
sets the value of treeFraction as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of trees using treeFraction_constant

*Inputs*
 - info helper for array

*Outputs*
 - land.states.treeFraction: an extra forcing that creates a time series of constant treeFraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
treeFraction_constant