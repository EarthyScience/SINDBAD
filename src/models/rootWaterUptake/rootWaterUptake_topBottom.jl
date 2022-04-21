export rootWaterUptake_topBottom

struct rootWaterUptake_topBottom <: rootWaterUptake
end

function compute(o::rootWaterUptake_topBottom, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		(pawAct, wRootUptake) ∈ land.states
		soilW ∈ land.pools
		transpiration ∈ land.fluxes
	end
	# get the transpiration
	for sl in 1:helpers.pools.water.nZix.soilW
		soilWAvail = pawAct[sl]
		contrib = minimum(transpiration, soilWAvail)
		wRootUptake[sl] = contrib
		transpiration = transpiration-contrib
	end

	## pack land variables
	@pack_land begin
		wRootUptake => land.states
	end
	return land
end

function update(o::rootWaterUptake_topBottom, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		wRootUptake ∈ land.states
	end

	## update variables
	# extract from top to bottom & update soil moisture 
	for sl in 1:helpers.pools.water.nZix.soilW 
		soilW[sl] = soilW[sl] - wRootUptake[sl]; 
	end 

	## pack land variables
	@pack_land soilW => land.pools
	return land
end

@doc """
calculates the rootUptake from each of the soil layer from top to bottom

---

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_topBottom

*Inputs*
 - land.fluxes.transpiration: actual transpirationiration
 - land.pools.soilW: soil moisture
 - land.states.pawAct: plant available water [pix, zix]

*Outputs*
 - land.states.wRootUptake: moisture uptake from each soil layer [nPix, nZix of soilW]

# update

update pools and states in rootWaterUptake_topBottom

 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala

*Notes*
 - assumes that the uptake is prioritized from top to bottom; irrespective of root fraction of the layers
"""
rootWaterUptake_topBottom