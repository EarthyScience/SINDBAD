export runoffOverland_Inf

struct runoffOverland_Inf <: runoffOverland
end

function compute(o::runoffOverland_Inf, forcing, land, infotem)

	## unpack land variables
	@unpack_land runoffInfiltration ∈ land.fluxes


	## calculate variables
	runoffOverland = runoffInfiltration

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
calculates total overland runoff that passes to the surface storage

---

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_Inf

*Inputs*
 - land.fluxes.runoffInfiltration: infiltration excess runoff

*Outputs*
 - land.fluxes.runoffOverland : runoff over land [mm/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
runoffOverland_Inf