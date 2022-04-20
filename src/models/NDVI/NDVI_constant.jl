export NDVI_constant

@bounds @describe @units @with_kw struct NDVI_constant{T1} <: NDVI
	constantNDVI::T1 = 1.0 | (0.0, 1.0) | "NDVI" | ""
end

function compute(o::NDVI_constant, forcing, land, helpers)
	## unpack parameters
	@unpack_NDVI_constant o

	## calculate variables
	NDVI = constantNDVI

	## pack land variables
	@pack_land NDVI => land.states
	return land
end

@doc """
sets the value of NDVI as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Normalized difference vegetation index using NDVI_constant

*Inputs*

*Outputs*
 - land.states.NDVI: an extra forcing that creates a time series of constant NDVI
 - land.states.NDVI

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
NDVI_constant