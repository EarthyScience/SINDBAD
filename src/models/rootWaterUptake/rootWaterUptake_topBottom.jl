export rootWaterUptake_topBottom, rootWaterUptake_topBottom_h
"""
calculates the rootUptake from each of the soil layer from top to bottom

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rootWaterUptake_topBottom{T} <: rootWaterUptake
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::rootWaterUptake_topBottom, forcing, land, infotem)
	# @unpack_rootWaterUptake_topBottom o
	return land
end

function compute(o::rootWaterUptake_topBottom, forcing, land, infotem)
	@unpack_rootWaterUptake_topBottom o

	## unpack variables
	@unpack_land begin
		(pawAct, wRootUptake) ∈ land.states
		soilW ∈ land.pools
		transpiration ∈ land.fluxes
	end
	#--> get the transpiration
	for sl in 1:infotem.pools.water.nZix.soilW
		soilWAvail = pawAct[sl]
		contrib = minimum(transpiration, soilWAvail)
		wRootUptake[sl] = contrib
		transpiration = transpiration-contrib
	end

	## pack variables
	@pack_land begin
		wRootUptake ∋ land.states
	end
	return land
end

function update(o::rootWaterUptake_topBottom, forcing, land, infotem)
	@unpack_rootWaterUptake_topBottom o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		wRootUptake ∈ land.states
	end

	## update variables
	#--> extract from top to bottom & update soil moisture 
	soilW = soilW - wRootUptake
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
calculates the rootUptake from each of the soil layer from top to bottom

# precompute:
precompute/instantiate time-invariant variables for rootWaterUptake_topBottom

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_topBottom

*Inputs:*
 - land.fluxes.transpiration: actual transpirationiration
 - land.pools.soilW: soil moisture
 - land.states.pawAct: plant available water [pix, zix]

*Outputs:*
 - land.states.wRootUptake: moisture uptake from each soil layer [nPix, nZix of soilW]

# update
update pools and states in rootWaterUptake_topBottom
 - land.pools.soilW

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - assumes that the uptake is prioritized from top to bottom; irrespective of root fraction of the layers
"""
function rootWaterUptake_topBottom_h end