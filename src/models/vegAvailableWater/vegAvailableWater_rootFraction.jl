export vegAvailableWater_rootFraction

struct vegAvailableWater_rootFraction <: vegAvailableWater
end

function compute(o::vegAvailableWater_rootFraction, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		p_wWP ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		zero ∈ helpers.numbers
	end

	pawAct = p_fracRoot2SoilD .* (max.(soilW + ΔsoilW - p_wWP, zero))

	## pack land variables
	@pack_land pawAct => land.vegAvailableWater
	return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants

---

# compute:
Plant available water using vegAvailableWater_rootFraction

*Inputs*
 - land.pools.soilW
 - land.rootFraction.constantRootFrac
 - land.states.maxRootD
 - land.states.p_

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW
 - land.states.pawAct as nPix;nZix for soilW

# precompute:
precompute/instantiate time-invariant variables for vegAvailableWater_rootFraction


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_rootFraction