export vegFraction_scaledEVI

@bounds @describe @units @with_kw struct vegFraction_scaledEVI{T1} <: vegFraction
	EVIscale::T1 = 1.0 | (0.0, 5.0) | "scalar for EVI" | ""
end

function compute(o::vegFraction_scaledEVI, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_vegFraction_scaledEVI o

	## unpack land variables
	@unpack_land begin
		EVI ∈ land.states
		𝟙 ∈ helpers.numbers		
	end


	## calculate variables
	vegFraction = min(EVI * EVIscale, 𝟙)

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of vegFraction by scaling the EVI value

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledEVI

*Inputs*
 - land.states.EVI : current EVI value

*Outputs*
 - land.states.vegFraction: current vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 06.02.2020 [ttraut]  
 - 1.1 on 05.03.2020 [ttraut]: apply the min function

*Created by:*
 - ttraut
"""
vegFraction_scaledEVI