export interception_vegFraction

@bounds @describe @units @with_kw struct interception_vegFraction{T1} <: interception
	pInt::T1 = 1.0 | (0.01, 5.0) | "maximum interception storage" | "mm"
end

function compute(o::interception_vegFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_interception_vegFraction o

	## unpack land variables
	@unpack_land begin
		(WBP, vegFraction) ∈ land.states
		rain ∈ land.rainSnow
	end
	# calculate interception loss
	intCap = pInt * vegFraction
	interception = min(intCap, rain)
	# update the available water
	WBP = WBP - interception

	## pack land variables
	@pack_land begin
		interception => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
computes canopy interception evaporation as a fraction of vegetation cover

# Parameters
$(PARAMFIELDS)

---

# compute:
Interception evaporation using interception_vegFraction

*Inputs*
 - land.states.vegFraction

*Outputs*
 -
 - land.states.WBP: updates the water balance pool [mm]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 27.11.2019 [skoiralal]: moved contents from prec, handling of vegFraction from s.cd  

*Created by:*
 - ttraut
"""
interception_vegFraction