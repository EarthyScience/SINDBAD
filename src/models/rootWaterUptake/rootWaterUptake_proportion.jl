export rootWaterUptake_proportion

struct rootWaterUptake_proportion <: rootWaterUptake
end

function compute(o::rootWaterUptake_proportion, forcing, land, infotem)

	## unpack land variables
	@unpack_land begin
		pawAct ∈ land.vegAvailableWater
		soilW ∈ land.pools
		transpiration ∈ land.fluxes
		ΔsoilW ∈ land.states
	end
	# get the transpiration
	transp = transpiration
	pawActTotal = sum(pawAct)
	wRootUptake = copy(pawAct)
	# extract from top to bottom
	for sl in 1:infotem.pools.water.nZix.soilW
		soilWAvailProp = max(0.0, pawAct[sl] / (pawActTotal + 0.0001)); # + 0.0001 is  necessary because supply can be 0 -> 0 / 0 = NaN
		contrib = transp * soilWAvailProp
		wRootUptake[sl] = contrib; #
		ΔsoilW[sl] = ΔsoilW[sl] - wRootUptake[sl]
	end

	## pack land variables
	@pack_land begin
		wRootUptake => land.states
		ΔsoilW => land.states
	end
	return land
end

function update(o::rootWaterUptake_proportion, forcing, land, infotem)

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end

	## update variables
	# update soil moisture
	soilW = soilW + ΔsoilW

	# reset soil moisture changes to zero
	ΔsoilW = ΔsoilW - ΔsoilW

	## pack land variables
	@pack_land begin
		soilW => land.pools
		ΔsoilW => land.states
	end
	return land
end

@doc """
calculates the rootUptake from each of the soil layer proportional to the root fraction

---

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_proportion

*Inputs*
 - land.fluxes.transpiration: actual transpiration
 - land.pools.soilW: soil moisture
 - land.states.pawAct: plant available water [pix, zix]

*Outputs*
 - land.states.wRootUptake: moisture uptake from each soil layer [nPix, nZix of soilW]

# update

update pools and states in rootWaterUptake_proportion

 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 13.03.2020 [ttraut]:  

*Created by:*
 - ttraut

*Notes*
 - assumes that the uptake from each layer remains proportional to the root fraction
"""
rootWaterUptake_proportion