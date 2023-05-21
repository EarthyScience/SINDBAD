export vegFraction_constant

@bounds @describe @units @with_kw struct vegFraction_constant{T1} <: vegFraction
	constantVegFrac::T1 = 0.5 | (0.3, 0.9) | "Vegetation fraction" | ""
end

function compute(o::vegFraction_constant, forcing, land, helpers)
	## unpack parameters
	@unpack_vegFraction_constant o

	## calculate variables
	vegFraction = constantVegFrac

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of vegFraction as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_constant

*Inputs*
 - constantvegFraction

*Outputs*
 - land.states.vegFraction: an extra forcing with a constant vegFraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
vegFraction_constant