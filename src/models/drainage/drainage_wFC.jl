export drainage_wFC

struct drainage_wFC <: drainage
end


function precompute(o::drainage_wFC, forcing, land, helpers)
	## instantiate drainage
	drainage = zeros(helpers.numbers.numType, length(land.pools.soilW))
	## pack land variables
	@pack_land drainage => land.drainage
	return land
end

function compute(o::drainage_wFC, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		drainage ∈ land.drainage
		(p_nsoilLayers, p_wFC) ∈ land.soilWBase
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		𝟘 ∈ helpers.numbers
	end

	## calculate drainage
	for sl in 1:length(land.pools.soilW)-1
		holdCap = p_wSat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
		lossCap = soilW[sl] + ΔsoilW[sl]
		drainage[sl] = max(soilW[sl] + ΔsoilW[sl] - p_wFC[sl], 𝟘)
		drainage[sl] = min(drainage[sl], holdCap, lossCap)
		ΔsoilW[sl] = ΔsoilW[sl] - drainage[sl]
		ΔsoilW[sl+1] = ΔsoilW[sl+1] + drainage[sl]
	end


	## pack land variables
	@pack_land begin
		drainage => land.drainage
		ΔsoilW => land.states
	end
	return land
end

function update(o::drainage_wFC, forcing, land, helpers)
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
downward flow of moisture [drainage] in soil layers based on overflow over field capacity

---

# compute:
Recharge the soil using drainage_wFC

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilWBase.p_wFC: field capacity of soil in mm
 - land.states.WBP amount of water that can potentially drain

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [groundWRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_wFC

 - land.pools.soilW
 - land.states.WBP

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency  

*Created by:*
 - mjung
 - skoirala
"""
drainage_wFC