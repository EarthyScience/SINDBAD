export drainage_kUnsat

struct drainage_kUnsat <: drainage
end

function precompute(o::drainage_kUnsat, forcing, land, helpers)
	## instantiate drainage
	drainage = zeros(helpers.numbers.numType, helpers.pools.water.nZix.soilW) 
	## pack land variables
	@pack_land drainage => land.drainage
	return land
end

function compute(o::drainage_kUnsat, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		drainage ∈ land.drainage
		unsatK ∈ land.soilProperties
		(p_wSat, p_β, p_kFC, p_kSat) ∈ land.soilWBase
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end

	for sl in 1:helpers.pools.water.nZix.soilW-1
		holdCap = p_wSat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
		lossCap = soilW[sl] + ΔsoilW[sl]
		drainage[sl] = unsatK(land, helpers, sl)
		drainage[sl] = min(drainage[sl], holdCap, lossCap)
	end

	drainage[end] = helpers.numbers.zero

	## pack land variables
	@pack_land drainage => land.drainage
	return land
end

@doc """
computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

---

# compute:
Recharge the soil using drainage_kUnsat

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [gwRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_kUnsat

 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
drainage_kUnsat