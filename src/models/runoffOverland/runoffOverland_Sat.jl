export runoffOverland_Sat

struct runoffOverland_Sat <: runoffOverland
end

function compute(o::runoffOverland_Sat, forcing, land, helpers)

	## unpack land variables
	@unpack_land runoffSaturation ∈ land.fluxes


	## calculate variables
	runoffOverland = runoffSaturation

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
calculates total overland runoff that passes to the surface storage

---

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_Sat

*Inputs*
 - land.fluxes.runoffSaturation: saturation excess runoff

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
runoffOverland_Sat