export rootMaximumDepth_fracSoilD

@bounds @describe @units @with_kw struct rootMaximumDepth_fracSoilD{T1} <: rootMaximumDepth
	fracRootD2SoilD::T1 = 0.5 | (0.1, 0.8) | "root depth as a fraction of soil depth" | ""
end

function compute(o::rootMaximumDepth_fracSoilD, forcing, land, infotem)
	## unpack parameters
	@unpack_rootMaximumDepth_fracSoilD o

	## calculate variables
	# get the soil thickness & root distribution information from input
	maxRootDepth = sum(infotem.pools.water.layerThickness.soilW) * fracRootD2SoilD
	# disp(["the maxRootD scalar: " fracRootD2SoilD])

	## pack land variables
	@pack_land maxRootDepth => land.states
	return land
end

@doc """
sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD

# Parameters
$(PARAMFIELDS)

---

# compute:
Maximum rooting depth using rootMaximumDepth_fracSoilD

*Inputs*
 - infotem.pools.water.layerThickness.soilW

*Outputs*
 - land.states.maxRootDepth: The maximum rooting depth in mm

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
rootMaximumDepth_fracSoilD