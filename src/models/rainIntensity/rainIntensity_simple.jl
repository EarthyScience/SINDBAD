export rainIntensity_simple

@bounds @describe @units @with_kw struct rainIntensity_simple{T1} <: rainIntensity
	rainIntFactor::T1 = 0.04167 | (0.0, 1.0) | "factor to convert daily rainfall to rainfall intensity" | ""
end

function compute(o::rainIntensity_simple, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_rainIntensity_simple o
	@unpack_forcing Rain ∈ forcing

	## calculate variables
	rainInt = Rain * rainIntFactor

	## pack land variables
	@pack_land rainInt => land.rainIntensity
	return land
end

@doc """
stores the time series of rainfall intensity

# Parameters
$(PARAMFIELDS)

---

# compute:
Set rainfall intensity using rainIntensity_simple

*Inputs*
 - forcing.Rain

*Outputs*
 - land.rainIntensity.rainInt: Intesity of rainfall during the day
 - None

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainIntensity_simple