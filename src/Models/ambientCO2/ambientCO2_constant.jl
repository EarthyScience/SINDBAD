export ambientCO2_constant

@bounds @describe @units @with_kw struct ambientCO2_constant{T1} <: ambientCO2
	constantambCO2::T1 = 400.0 | (200.0, 5000.0) | "atmospheric CO2 concentration" | "ppm"
end

function compute(o::ambientCO2_constant, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_ambientCO2_constant o

	## calculate variables
	ambCO2 = constantambCO2

	## pack land variables
	@pack_land ambCO2 => land.states
	return land
end

@doc """
sets the value of ambCO2 as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Set/get ambient co2 concentration using ambientCO2_constant

*Inputs*

*Outputs*
 - land.states.ambCO2: a constant state of ambient CO2

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
ambientCO2_constant