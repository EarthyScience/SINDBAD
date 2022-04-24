export fAPAR_vegFraction

@bounds @describe @units @with_kw struct fAPAR_vegFraction{T1} <: fAPAR
	vegFracTofAPAR::T1 = 0.00002 | (0.00001, 0.99) | "linear fraction of fAPAR and vegFraction" | ""
end


function compute(o::fAPAR_vegFraction, forcing, land, helpers)
	@unpack_fAPAR_vegFraction o

	## unpack land variables
	@unpack_land vegFraction ∈ land.states

	## calculate variables
	fAPAR = vegFracTofAPAR * vegFraction

	## pack land variables
	@pack_land fAPAR => land.states
	return land
end

@doc """
sets the value of fAPAR as a linear function of vegetation fraction

# Parameters
$(PARAMFIELDS)

---

# compute:
Fraction of absorbed photosynthetically active radiation from vegFraction

*Inputs*
 - land.states.vegFraction: vegetated fraction, which needs vegFraction module to be activated

*Outputs*
 - land.states.fAPAR: fAPAR as a fraction of vegetation fraction

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
fAPAR_vegFraction