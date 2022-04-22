export runoffOverland_Inf

struct runoffOverland_Inf <: runoffOverland
end

function compute(o::runoffOverland_Inf, forcing, land, helpers)

	## unpack land variables
	@unpack_land runoffInfExc ∈ land.fluxes


	## calculate variables
	runoffOverland = runoffInfExc

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
assumes overland flow to be infiltration excess runoff
---

# compute:

*Inputs*
 - land.fluxes.runoffInfExc: infiltration excess runoff

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