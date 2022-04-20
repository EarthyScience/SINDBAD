export WUE_constant

@bounds @describe @units @with_kw struct WUE_constant{T1} <: WUE
	constantWUE::T1 = 4.1 | (1.0, 10.0) | "mean FluxNet WUE" | "gC/mmH2O"
end

function compute(o::WUE_constant, forcing, land, infotem)
	## unpack parameters
	@unpack_WUE_constant o

	## calculate variables
	AoE = constantWUE

	## pack land variables
	@pack_land AoE => land.WUE
	return land
end

@doc """
calculates the WUE/AOE as a constant in space & time

# Parameters
$(PARAMFIELDS)

---

# compute:
Estimate wue using WUE_constant

*Inputs*

*Outputs*
 - land.WUE.AoE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUE across fluxNet  sites
 - skoirala
"""
WUE_constant