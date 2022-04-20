export NDWI_constant

@bounds @describe @units @with_kw struct NDWI_constant{T1} <: NDWI
	constantNDWI::T1 = 1.0 | (0.0, 1.0) | "NDWI" | ""
end

function compute(o::NDWI_constant, forcing, land, helpers)
	## unpack parameters
	@unpack_NDWI_constant o

	## calculate variables
	NDWI = constantNDWI

	## pack land variables
	@pack_land NDWI => land.states
	return land
end

@doc """
sets the value of NDWI as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Normalized difference water index using NDWI_constant

*Inputs*

*Outputs*
 - land.states.NDWI: an extra forcing that creates a time series of constant NDWI
 - land.states.NDWI

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
NDWI_constant