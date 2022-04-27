export runoffOverland_Sat

struct runoffOverland_Sat <: runoffOverland
end

function compute(o::runoffOverland_Sat, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land runoffSatExc ∈ land.fluxes


	## calculate variables
	runoffOverland = runoffSatExc

	## pack land variables
	@pack_land runoffOverland => land.fluxes
	return land
end

@doc """
assumes overland flow to be saturation excess runoff

---

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_Sat

*Inputs*
 - land.fluxes.runoffSatExc: saturation excess runoff

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