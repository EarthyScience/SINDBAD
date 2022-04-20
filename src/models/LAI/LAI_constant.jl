export LAI_constant

@bounds @describe @units @with_kw struct LAI_constant{T1} <: LAI
	constantLAI::T1 = 3.0 | (1.0, 12.0) | "LAI" | "m2/m2"
end

function compute(o::LAI_constant, forcing, land, infotem)
	## unpack parameters
	@unpack_LAI_constant o

	## calculate variables
	LAI = constantLAI

	## pack land variables
	@pack_land LAI => land.states
	return land
end

@doc """
sets the value of LAI as a constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Leaf area index using LAI_constant

*Inputs*

*Outputs*
 - land.states.LAI: an extra forcing that creates a time series of constant LAI

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala
"""
LAI_constant