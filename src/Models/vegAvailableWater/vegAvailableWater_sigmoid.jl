export vegAvailableWater_sigmoid

@bounds @describe @units @with_kw struct vegAvailableWater_sigmoid{T1} <: vegAvailableWater
	exp_factor::T1 = 1.0 | (0.02, 3.0) | "multiplier of B factor of exponential rate" | ""
end

function compute(o::vegAvailableWater_sigmoid, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_vegAvailableWater_sigmoid o

	## unpack land variables
	@unpack_land begin
		(p_wWP, p_wFC, p_wSat, p_β) ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		(𝟘, 𝟙) ∈ helpers.numbers
	end

	θ_dos = (soilW + ΔsoilW) ./ p_wSat
	θ_fc_dos = p_wFC ./ p_wSat
	soilWStress = clamp.(𝟙 ./ (𝟙 .+ exp.(-exp_factor .* p_β .* (θ_dos - θ_fc_dos))), 𝟘, 𝟙)
	maxWater =  max.(soilW + ΔsoilW - p_wWP, 𝟘)
	PAW = p_fracRoot2SoilD .* maxWater .* soilWStress

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