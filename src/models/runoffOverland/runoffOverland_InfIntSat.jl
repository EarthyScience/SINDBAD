export runoffOverland_InfIntSat

struct runoffOverland_InfIntSat <: runoffOverland
end

function compute(o::runoffOverland_InfIntSat, forcing, land, infotem)

	## unpack land variables
	@unpack_land (runoffInfiltration, runoffInterflow, runoffSaturation) ∈ land.fluxes


	## calculate variables
	runoffOverland = runoffInfiltration + runoffInterflow + runoffSaturation

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
calculates total overland runoff that passes to the surface storage

---

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_InfIntSat

*Inputs*
 - land.fluxes.runoffInfiltration: infiltration excess runoff
 - land.fluxes.runoffInterflow: intermittent flow
 - land.fluxes.runoffSaturation: saturation excess runoff

*Outputs*
 - land.fluxes.runoffOverland : runoff from land [mm/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - skoirala
"""
runoffOverland_InfIntSat