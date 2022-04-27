export runoffOverland_InfIntSat

struct runoffOverland_InfIntSat <: runoffOverland
end

function compute(o::runoffOverland_InfIntSat, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land (runoffInfExc, runoffInterflow, runoffSatExc) ∈ land.fluxes


	## calculate variables
	runoffOverland = runoffInfExc + runoffInterflow + runoffSatExc

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs

---

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_InfIntSat

*Inputs*
 - land.fluxes.runoffInfExc: infiltration excess runoff
 - land.fluxes.runoffInterflow: intermittent flow
 - land.fluxes.runoffSatExc: saturation excess runoff

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