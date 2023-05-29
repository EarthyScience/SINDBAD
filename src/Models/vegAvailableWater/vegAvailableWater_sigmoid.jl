export vegAvailableWater_sigmoid

@bounds @describe @units @with_kw struct vegAvailableWater_sigmoid{T1} <: vegAvailableWater
	exp_factor::T1 = 1.0 | (0.02, 3.0) | "multiplier of B factor of exponential rate" | ""
end

function precompute(o::vegAvailableWater_sigmoid, forcing, land, helpers)
	## unpack parameters
	@unpack_vegAvailableWater_sigmoid o

	## unpack land variables
	@unpack_land begin
		soilW ∈ land.pools
	end

	θ_dos = zero(soilW)
	θ_fc_dos = zero(soilW)
	PAW = zero(soilW)
	soilWStress = zero(soilW)
	maxWater = zero(soilW)

	## pack land variables
	@pack_land (θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) => land.vegAvailableWater
	return land
end

function compute(o::vegAvailableWater_sigmoid, forcing, land, helpers)
	## unpack parameters
	@unpack_vegAvailableWater_sigmoid o

	## unpack land variables
	@unpack_land begin
		(p_wWP, p_wFC, p_wSat, p_β) ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		(𝟘, 𝟙) ∈ helpers.numbers
		(θ_dos, θ_fc_dos, PAW, soilWStress, maxWater) ∈ land.vegAvailableWater
	end
	for sl in eachindex(soilW)
		θ_dos = (soilW[sl] + ΔsoilW[sl]) / p_wSat[sl]
		θ_fc_dos = p_wFC[sl] / p_wSat[sl]
		tmpSoilWStress = clamp(𝟙 / (𝟙 + exp(-exp_factor * p_β[sl] * (θ_dos - θ_fc_dos))), 𝟘, 𝟙)
		soilWStress = ups(soilWStress, tmpSoilWStress, sl)
		maxWater =  clamp(soilW[sl] + ΔsoilW[sl] - p_wWP[sl], 𝟘, 𝟙)
		PAW = ups(PAW, p_fracRoot2SoilD[sl] * maxWater * tmpSoilWStress, sl)		
	end

	## pack land variables
	@pack_land (PAW, soilWStress) => land.vegAvailableWater
	return land
end

@doc """
calculate the actual amount of water that is available for plants

# Parameters
$(PARAMFIELDS)

---

# compute:
Plant available water using vegAvailableWater_sigmoid

*Inputs*
 - land.pools.soilW

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
vegAvailableWater_sigmoid