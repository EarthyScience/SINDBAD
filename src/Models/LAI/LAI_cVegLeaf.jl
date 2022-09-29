export LAI_cVegLeaf

@bounds @describe @units @with_kw struct LAI_cVegLeaf{T1} <: LAI
	SLA::T1 = 0.016f0 | (0.01f0, 0.024f0) | "specific leaf area" | "m^2.gC^-1"
end

function compute(o::LAI_cVegLeaf, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_LAI_cVegLeaf o

	@unpack_land cVegLeaf ∈ land.pools

	## calculate variables
	cVegLeafTotal = sum(cVegLeaf)
	LAI = cVegLeafTotal* SLA

	## pack land variables
	@pack_land LAI => land.states
	return land
end

@doc """
sets the value of land.states.LAI from the carbon in the leaves of the previous time step

# Parameters
$(PARAMFIELDS)

---

# compute:
Leaf area index using LAI_cVegLeaf

*Inputs*
 - land.pools.cEco[cVegLeafZix]: carbon in the leave

*Outputs*
 - land.states.LAI: the value of LAI for current time step
 - land.states.LAI

---

# Extended help

*References*

*Versions*
 - 1.0 on 05.05.2020 [sbesnard]

*Created by:*
 - sbesnard
"""
LAI_cVegLeaf