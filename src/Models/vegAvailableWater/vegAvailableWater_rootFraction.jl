export vegAvailableWater_rootFraction

struct vegAvailableWater_rootFraction <: vegAvailableWater
end

function instantiate(o::vegAvailableWater_rootFraction, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		soilW ∈ land.pools
	end

	PAW = zero(soilW)

	## pack land variables
	@pack_land PAW => land.vegAvailableWater
	return land
end

function compute(o::vegAvailableWater_rootFraction, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		p_wWP ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		𝟘 ∈ helpers.numbers
		PAW ∈ land.vegAvailableWater
	end
	for sl in eachindex(soilW)
		PAW_sl = p_fracRoot2SoilD[sl] * (max(soilW[sl] + ΔsoilW[sl] - p_wWP[sl], 𝟘))
		@rep_elem PAW_sl => (PAW, sl, :soilW)
	end


	@pack_land PAW => land.vegAvailableWater
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

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD
 - land.states.PAW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_rootFraction