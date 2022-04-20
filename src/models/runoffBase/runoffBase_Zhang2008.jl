export runoffBase_Zhang2008

@bounds @describe @units @with_kw struct runoffBase_Zhang2008{T1} <: runoffBase
	bc::T1 = 0.001 | (0.0001, 0.02) | "base flow coefficient" | "day-1"
end

function compute(o::runoffBase_Zhang2008, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffBase_Zhang2008 o

	## unpack land variables
	@unpack_land groundW ∈ land.pools


	## calculate variables
	# simply assume that a fraction of the GWstorage is baseflow
	runoffBase = bc * groundW[1]
	# update GW pool
	## pack land variables
	@pack_land begin
		runoffBase => land.fluxes
	end
	return land
end

function update(o::runoffBase_Zhang2008, forcing, land, helpers)
	@unpack_runoffBase_Zhang2008 o

	## unpack variables
	@unpack_land runoffBase ∈ land.fluxes
	@unpack_land groundW ∈ land.pools

	## update variables
	groundW[1] = groundW[1] - runoffBase

	## pack land variables
	@pack_land groundW => land.pools
	return land
end

@doc """
computes baseflow from a linear ground water storage

# Parameters
$(PARAMFIELDS)

---

# compute:
Baseflow using runoffBase_Zhang2008

*Inputs*

*Outputs*
 - land.fluxes.runoffBase: base flow [mm/time]

# update

update pools and states in runoffBase_Zhang2008

 - land.pools.groundW: groundwater storage [mm]

---

# Extended help

*References*
 - Zhang, Y. Q., Chiew, F. H. S., Zhang, L., Leuning, R., & Cleugh, H. A. (2008).  Estimating catchment evaporation and runoff using MODIS leaf area index & the Penman‐Monteith equation.  Water Resources Research, 44[10].

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
runoffBase_Zhang2008