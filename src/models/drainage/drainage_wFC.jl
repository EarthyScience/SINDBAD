export drainage_wFC

struct drainage_wFC <: drainage
end

function compute(o::drainage_wFC, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		(p_nsoilLayers, p_wFC) ∈ land.soilWBase
		soilW ∈ land.pools
		soilWPerc ∈ land.fluxes
	end
	# get the number of soil layers
	helpers.pools.water.nZix.soilW = p_nsoilLayers
	soilWFlow[1] = soilWPerc
	for sl in 1:helpers.pools.water.nZix.soilW-1
		# drain excess moisture in oversaturation
		maxDrain = max(soilW[sl] - p_wFC[sl], 0)
		# store the drainage flux
		soilWFlow[sl+1] = maxDrain
	end

	## pack land variables
	@pack_land begin
		soilWFlow => land.states
	end
	return land
end

function update(o::drainage_wFC, forcing, land, helpers)

	## unpack variables
	@unpack_land (soilW[sl, 1], maxDrain) ∈ land.fluxes

	## update variables
		# update storages
		soilW[sl] = soilW[sl] - maxDrain
		soilW[sl+1] = soilW[sl+1] + maxDrain

	## pack land variables
	@pack_land soilW => land.pools
	return land
end

@doc """
computes the downward flow of moisture [drainage] in soil layers based on overflow from the upper layers

---

# compute:
Recharge the soil using drainage_wFC

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilWBase.p_wFC: field capacity of soil in mm
 - land.states.WBP amount of water that can potentially drain

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [gwRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_wFC

 - land.pools.soilW
 - land.states.WBP

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency  

*Created by:*
 - mjung
 - skoirala
"""
drainage_wFC