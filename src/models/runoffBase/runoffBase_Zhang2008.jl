export runoffBase_Zhang2008, runoffBase_Zhang2008_h
"""
computes baseflow from a linear ground water storage

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffBase_Zhang2008{T1} <: runoffBase
	bc::T1 = 0.001 | (0.0001, 0.02) | "base flow coefficient" | "day-1"
end

function precompute(o::runoffBase_Zhang2008, forcing, land, infotem)
	# @unpack_runoffBase_Zhang2008 o
	return land
end

function compute(o::runoffBase_Zhang2008, forcing, land, infotem)
	@unpack_runoffBase_Zhang2008 o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
	end
	# simply assume that a fraction of the GWstorage is baseflow
	runoffBase = bc * groundW[1]
	# update GW pool

	## pack variables
	@pack_land begin
		runoffBase ∋ land.fluxes
	end
	return land
end

function update(o::runoffBase_Zhang2008, forcing, land, infotem)
	@unpack_runoffBase_Zhang2008 o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
		runoffBase ∈ land.fluxes
	end

	## update variables
	groundW[1] = groundW[1] - runoffBase

	## pack variables
	@pack_land begin
		groundW ∋ land.pools
	end
	return land
end

"""
computes baseflow from a linear ground water storage

# precompute:
precompute/instantiate time-invariant variables for runoffBase_Zhang2008

# compute:
Baseflow using runoffBase_Zhang2008

*Inputs:*

*Outputs:*
 - land.fluxes.runoffBase: base flow [mm/time]

# update
update pools and states in runoffBase_Zhang2008
 - land.pools.groundW: groundwater storage [mm]

# Extended help

*References:*
 - Zhang, Y. Q., Chiew, F. H. S., Zhang, L., Leuning, R., & Cleugh, H. A. (2008).  Estimating catchment evaporation and runoff using MODIS leaf area index & the Penman‐Monteith equation.  Water Resources Research, 44[10].

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - Martin Jung [mjung]
"""
function runoffBase_Zhang2008_h end