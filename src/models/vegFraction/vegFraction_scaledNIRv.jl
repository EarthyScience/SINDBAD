export vegFraction_scaledNIRv

@bounds @describe @units @with_kw struct vegFraction_scaledNIRv{T1} <: vegFraction
	NIRvscale::T1 = 1.0 | (0.0, 5.0) | "scalar for NIRv" | ""
end

function compute(o::vegFraction_scaledNIRv, forcing, land, infotem)
	## unpack parameters
	@unpack_vegFraction_scaledNIRv o

	## unpack land variables
	@unpack_land begin
		NIRv ∈ land.states
		(zero, one) ∈ infotem.helpers
	end


	## calculate variables
	vegFraction = clamp(NIRv * NIRvscale, zero, one)

	## pack land variables
	@pack_land vegFraction => land.states
	return land
end

@doc """
sets the value of vegFraction by scaling the NIRv value

# Parameters
$(PARAMFIELDS)

---

# compute:
Fractional coverage of vegetation using vegFraction_scaledNIRv

*Inputs*
 - land.states.NIRv : current NIRv value

*Outputs*
 - land.states.vegFraction: current vegetation fraction
 - None

---

# Extended help

*References*
 -

*Versions*
 - 1.1 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
vegFraction_scaledNIRv