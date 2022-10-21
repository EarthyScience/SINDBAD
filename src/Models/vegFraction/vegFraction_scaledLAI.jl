export vegFraction_scaledLAI

@bounds @describe @units @with_kw struct vegFraction_scaledLAI{T1} <: vegFraction
	LAIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for LAI" | ""
end

function compute(o::vegFraction_scaledLAI, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_vegFraction_scaledLAI o

	## unpack land variables
	@unpack_land begin
		LAI ∈ land.states
		𝟙 ∈ helpers.numbers
	end

	## calculate variables
	vegFraction = min(LAI * LAIscale, 𝟙)

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of vegFraction by scaling the LAI value

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledLAI

*Inputs*
 - land.states.LAI : LAI

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
vegFraction_scaledLAI