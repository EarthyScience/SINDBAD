export rootWaterUptake_proportion, rootWaterUptake_proportion_h
"""
calculates the rootUptake from each of the soil layer proportional to the root fraction

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rootWaterUptake_proportion{T} <: rootWaterUptake
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::rootWaterUptake_proportion, forcing, land, infotem)
	# @unpack_rootWaterUptake_proportion o
	return land
end

function compute(o::rootWaterUptake_proportion, forcing, land, infotem)
	@unpack_rootWaterUptake_proportion o

	## unpack variables
	@unpack_land begin
		(pawAct, wRootUptake) ∈ land.states
		soilW ∈ land.pools
		transpiration ∈ land.fluxes
	end
	#--> get the transpiration
	transp = transpiration
	pawActTotal = sum(pawAct)
	#--> extract from top to bottom
	for sl in 1:infotem.pools.water.nZix.soilW
		soilWAvailProp = max(0.0, pawAct[sl] / pawActTotal); #necessary because supply can be 0 -> 0 / 0 = NaN
		contrib = transp * soilWAvailProp
		wRootUptake[sl] = contrib; #
	end

	## pack variables
	@pack_land begin
		wRootUptake ∋ land.states
	end
	return land
end

function update(o::rootWaterUptake_proportion, forcing, land, infotem)
	@unpack_rootWaterUptake_proportion o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		wRootUptake ∈ land.states
	end

	## update variables
	#--> update soil moisture
	for sl in 1:infotem.pools.water.nZix.soilW 
		soilW[sl] = soilW[sl] - wRootUptake[sl];
	end 

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
calculates the rootUptake from each of the soil layer proportional to the root fraction

# precompute:
precompute/instantiate time-invariant variables for rootWaterUptake_proportion

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_proportion

*Inputs:*
 - land.fluxes.transpiration: actual transpiration
 - land.pools.soilW: soil moisture
 - land.states.pawAct: plant available water [pix, zix]

*Outputs:*
 - land.states.wRootUptake: moisture uptake from each soil layer [nPix, nZix of soilW]

# update
update pools and states in rootWaterUptake_proportion
 - land.pools.soilW

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 13.03.2020 [ttraut]:  

*Created by:*
 - Tina Trautmann [ttraut]

*Notes:*
 - assumes that the uptake from each layer remains proportional to the root fraction
"""
function rootWaterUptake_proportion_h end