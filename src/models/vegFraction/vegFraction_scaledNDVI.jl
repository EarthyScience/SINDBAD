export vegFraction_scaledNDVI

@bounds @describe @units @with_kw struct vegFraction_scaledNDVI{T1} <: vegFraction
	NDVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NDVI" | ""
end

function compute(o::vegFraction_scaledNDVI, forcing, land, helpers)
	## unpack parameters
	@unpack_vegFraction_scaledNDVI o

	## unpack land variables
	@unpack_land begin
		NDVI ∈ land.states
		(zero, one) ∈ helpers.numbers
	end


	## calculate variables
	vegFraction = clamp(NDVI * NDVIscale, zero, one)

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of vegFraction by scaling the NDVI value

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledNDVI

*Inputs*
 - land.states.NDVI : current NDVI value

*Outputs*
 - land.states.vegFraction: current vegetation fraction

---

# Extended help

*References*
 -

*Versions*
 - 1.1 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
vegFraction_scaledNDVI