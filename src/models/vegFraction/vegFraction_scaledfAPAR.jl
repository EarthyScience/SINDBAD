export vegFraction_scaledfAPAR

@bounds @describe @units @with_kw struct vegFraction_scaledfAPAR{T1} <: vegFraction
	fAPARscale::T1 = 10.0 | (0.0, 20.0) | "scalar for fAPAR" | ""
end

function compute(o::vegFraction_scaledfAPAR, forcing, land, helpers)
	## unpack parameters
	@unpack_vegFraction_scaledfAPAR o

	## unpack land variables
	@unpack_land begin
		fAPAR ∈ land.states
		one ∈ helpers.numbers		
	end

	## calculate variables
	vegFraction = min(fAPAR * fAPARscale, one)

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of vegFraction by scaling the fAPAR value

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledfAPAR

*Inputs*
 - land.states.fAPAR : fAPAR value

*Outputs*
 - land.states.vegFraction: current vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.1 on 24.10.2020 [ttraut]: new module  

*Created by:*
 - sbesnard
"""
vegFraction_scaledfAPAR