export NIRv_constant

@bounds @describe @units @with_kw struct NIRv_constant{T1} <: NIRv
	constantNIRv::T1 = 1.0 | (0.0, 1.0) | "NIRv" | ""
end

function compute(o::NIRv_constant, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_NIRv_constant o

	## calculate variables
	NIRv = constantNIRv

	## pack land variables
	@pack_land NIRv => land.states
	return land
end

@doc """
sets the value of NIRv as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Near-infrared reflectance of terrestrial vegetation using NIRv_constant

*Inputs*

*Outputs*
 - land.states.NIRv: an extra forcing that creates a time series of constant NIRv
 - land.states.NIRv

---

# Extended help

*References*

*Versions*
 - 1.0 on 29.04.2020 [sbesnard]: new module  

*Created by:*
 - sbesnard
"""
NIRv_constant