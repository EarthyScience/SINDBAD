export soilProperties_Saxton2006, kSaxton2006, soilParamsSaxton2006

@bounds @describe @units @with_kw struct soilProperties_Saxton2006{T1, T2, T3, T4, T5} <: soilProperties
	DF::T1 = 1.0 | (0.9, 1.3) | "Density correction factor" | ""
	Rw::T2 = 0.0 | (0.0, 1.0) | "Weight fraction of gravel (decimal)" | "g g-1"
	matricSoilDensity::T3 = 2.65 | (2.5, 3.0) | "Matric soil density" | "g cm-3"
	gravelDensity::T4 = 2.65 | (2.5, 3.0) | "density of gravel material" | "g cm-3"
	EC::T5 = 36.0 | (30.0, 40.0) | "SElectrical conductance of a saturated soil extract" | "dS m-1 (dS/m = mili-mho cm-1)"
end

function precompute(o::soilProperties_Saxton2006, forcing, land, infotem)
	@unpack_soilProperties_Saxton2006 o

	## instantiate variables
	p_α = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_β = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_kFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_θFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ψFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_kWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_θWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ψWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_kSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_θSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ψSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)

	## pack land variables
	@pack_land (p_α, p_β, p_kFC, p_θFC, p_ψFC, p_kWP, p_θWP, p_ψWP, p_kSat, p_θSat, p_ψSat) => land.soilProperties
	return land
end

function compute(o::soilProperties_Saxton2006, forcing, land, infotem)
	## unpack parameters
	@unpack_soilProperties_Saxton2006 o

	## unpack land variables
	@unpack_land (p_α, p_β, p_kFC, p_θFC, p_ψFC, p_kWP, p_θWP, p_ψWP, p_kSat, p_θSat, p_ψSat) ∈ land.soilProperties
	@unpack_land (p_CLAY, p_ORGM, p_SAND) ∈ land.soilTexture

	## calculate variables
	# number of layers & creation of arrays
	# calculate & set the soil hydraulic properties for each layer
	for sl in 1:infotem.pools.water.nZix.soilW
		# (α, β, kSat, θSat, ψSat, kFC, θFC, ψFC, kWP, θWP, ψWP) = soilParamsSaxton2006(land, infotem, sl)
		CLAY = p_CLAY[sl]
		SAND = p_SAND[sl]
		# ORGM = p_ORGM[sl]
		ORGM = 0.0
		# CLAY = CLAY
		# SAND = SAND
		# ORGM = ORGM
		## Moisture regressions
		# θ_1500t: 1500 kPa moisture; first solution; #v
		# θ_1500: 1500 kPa moisture; #v
		θ_1500t = -0.024 * SAND + 0.487 * CLAY + 0.006 * ORGM + 0.005 * (SAND * ORGM) - 0.013 * (CLAY * ORGM) + 0.068 * (SAND * CLAY) + 0.031
		θ_1500 = θ_1500t + (0.14 * θ_1500t - 0.02)
		# θ_33t: 33 kPa moisture; first solution; #v
		# θ_33: 33 kPa moisture; normal density; #v
		θ_33t = -0.251 * SAND + 0.195 * CLAY + 0.011 * ORGM + 0.006 * (SAND * ORGM) - 0.027 * (CLAY * ORGM) + 0.452 * (SAND * CLAY) + 0.299
		θ_33 = θ_33t + (1.283 * (θ_33t) ^ 2 - 0.374 * θ_33t - 0.015)
		# θ_s_33t: SAT-33 kPa moisture; first solution; #v
		# θ_s_33: SAT-33 kPa moisture; normal density #v
		θ_s_33t = 0.278 * SAND + 0.034 * CLAY + 0.022 * ORGM - 0.018 * (SAND * ORGM) - 0.027 * (CLAY * ORGM) - 0.584 * (SAND * CLAY) + 0.078
		θ_s_33 = θ_s_33t + (0.636 * θ_s_33t - 0.107)
		# ψ_et: Tension at air entry; first solution; kPa
		# ψ_e: Tension at air entry [bubbling pressure], kPa
		ψ_et = abs(-21.67 * SAND - 27.93 * CLAY - 81.97 * θ_s_33 + 71.12 * (SAND * θ_s_33) + 8.29 * (CLAY * θ_s_33)
		- 14.05 * (SAND * CLAY) + 27.16)
		ψ_e = abs(ψ_et + (0.02 * (ψ_et ^ 2) - 0.113 * ψ_et - 0.70))
		# θ_s: Saturated moisture [0 kPa], normal density, #v
		# rho_N: Normal density; g cm-3
		θ_s = θ_33 + θ_s_33 - 0.097 * SAND + 0.043
		rho_N = (1.0 - θ_s) * 2.65
		## Density effects
		# rho_DF: Adjusted density; g cm-3
		# θ_s_DF: Saturated moisture [0 kPa], adjusted density, #v
		# θ_33_DF: 33 kPa moisture; adjusted density; #v
		# θ_s_33_DF: SAT-33 kPa moisture; adjusted density; #v
		# DF: Density adjustment Factor [0.9-1.3]
		rho_DF = rho_N * DF
		# θ_s_DF = 1 - (rho_DF / 2.65); # original but does not include θ_s
		θ_s_DF = θ_s * (1.0 - (rho_DF / 2.65)); # may be includes θ_s
		θ_33_DF = θ_33 - 0.2 * (θ_s - θ_s_DF)
		θ_1500_DF = θ_1500 - 0.2 * (θ_s - θ_s_DF)
		θ_s_33_DF = θ_s_DF - θ_33_DF
		## Moisture-Tension
		# A, B: Coefficients of moisture-tension, Eq. [11]
		# ψ_θ: Tension at moisture θ; kPa
		B = (log(1500) - log(33)) / (log(θ_33) - log(θ_1500))
		A = exp(log(33) + B * log(θ_33))
		# ψ_θ = A * ((θ) ^ (-B))
		# ψ_33 = 33.0 - ((θ - θ_33) * (33.0 - ψ_e)) / (θ_s - θ_33)
		## Moisture-Conductivity
		# λ: Slope of logarithmic tension-moisture curve
		# Ks: Saturated conductivity [matric soil], mm h-1
		# K_θ: Unsaturated conductivity at moisture θ; mm h-1
		λ = 1 / B
		Ks = 1930 * ((θ_s - θ_33) ^ (3 - λ)) * 24
		# K_θ = Ks * ((θ / θ_s) ^ (3 + (2 / λ)))
		## Gravel Effects
		# rho_B: Bulk soil density [matric plus gravel], g cm-3
		# αRho: Matric soil density/gravel density [2.65] = rho/2.65
		# Rv: Volume fraction of gravel [decimal], g cm -3
		# Rw: Weight fraction of gravel [decimal], g g-1
		# Kb: Saturated conductivity [bulk soil], mm h-1
		αRho = matricSoilDensity / gravelDensity
		Rv = (αRho * Rw) / (1.0 - Rw * (1.0 - αRho))
		rho_B = rho_N * (1.0 - Rv) + Rv * 2.65
		# PAW_B = PAW * (1.0 - Rv)
		Kb = Ks * ((1.0 - Rw) / (1.0 - Rw * (1.0 - (3 * αRho / 2))))
		## Salinity Effects
		# ϕ_o: Osmotic potential at θ = θ_s; kPa
		# ϕ_o_θ: Osmotic potential at θ < θ_s; kPa
		# EC: Electrical conductance of a saturated soil extract, dS m-1 [dS/m = mili-mho cm-1]
		phi_o = 36 * EC
		# ϕ_o_θ = (θ_s / θ) * 36 / EC
		## Assign the variables for returning
		α = A
		β = B
		# θSat = θ_s_DF
		θSat = θ_s
		kSat = Kb
		ψSat = 0.0
		# θFC = θ_33_DF
		θFC = θ_33
		kFC = kSat * ((θFC / θSat) ^ (3 + (2 / λ)))
		ψFC = 33
		# θWP = θ_1500_DF
		θWP = θ_1500
		ψWP = 1500
		kWP = kSat * ((θWP / θSat) ^ (3 + (2 / λ)))
		# @show CLAY, SAND, α, β, kSat, θSat, ψSat, kFC, θFC, ψFC, kWP, θWP, ψWP

		p_α[sl] = α
		p_β[sl] = β
		p_kFC[sl] = kFC
		p_θFC[sl] = θFC
		p_ψFC[sl] = ψFC
		p_kWP[sl] = kWP
		p_θWP[sl] = θWP
		p_ψWP[sl] = ψWP
		p_kSat[sl] = kSat
		p_θSat[sl] = θSat
		p_ψSat[sl] = ψSat
	end
	# generate the function handle to calculate soil hydraulic property
	p_kUnsatFuncH = kSaxton2006

	## pack land variables
	@pack_land (p_kFC, p_kSat, p_kUnsatFuncH, p_kWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) => land.soilProperties
	return land
end

@doc """
assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.p_

# Parameters
$(PARAMFIELDS)

---

# compute:
Soil properties (hydraulic properties) using soilProperties_Saxton2006

*Inputs*
 - : texture-based Saxton parameters
 - calcSoilParamsSaxton2006: function to calculate hydraulic properties
 - info
 - land.soilTexture.p_[CLAY/SAND]

*Outputs*
 - hydraulic conductivity [k], matric potention [ψ] & porosity  (θ) at saturation [Sat], field capacity [FC], & wilting point  (WP)
 - land.soilProperties.p_[α/β]: properties of moisture-retention curves
 - land.soilProperties.p_θFC/kFC/ψFC/sFC
 - land.soilProperties.p_θSat/kSat/ψSat/sSat
 - land.soilProperties.p_θWP/kWP/ψWP/sWP
 - None

# precompute:
precompute/instantiate time-invariant variables for soilProperties_Saxton2006


---

# Extended help

*References*
 - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by  texture & organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.

*Versions*
 - 1.0 on 21.11.2019
 - 1.1 on 03.12.2019 [skoirala]: handling potentail vertical distribution of soil texture  

*Created by:*
 - skoirala
"""
soilProperties_Saxton2006

"""
calculates the soil hydraulic conductivity for a given moisture based on Saxton; 2006

# Inputs:
 - land.pools.soilW[sl]
 - land.soilWBase.p_[wSat/β/kSat]: hydraulic parameters for each soil layer

# Outputs:
 - K: the hydraulic conductivity at unsaturated land.pools.soilW [in mm/day]
 - is calculated using original equation if infotem.flags.useLookupK == 0.0
 - uses precomputed lookup table if infotem.flags.useLookupK == 1

# Modifies:
 - None

# Extended help

# References:
 - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by  texture & organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.

# Versions:
 - 1.0 on 22.11.2019 [skoirala]:
 - 1.1 on 03.12.2019 [skoirala]: included the option to handle lookup table when set to true  from modelRun.json  

# Created by:
 - skoirala

# Notes:
 - This function is a part of pSoil; but making the looking up table & setting the soil  properties is handled by soilWBase [by calling this function]
 - is also used by all approaches depending on kUnsat within time loop of coreTEM
"""
function kSaxton2006(land, infotem, sl)
	@unpack_land begin
		(p_β, p_kSat, p_wSat) ∈ land.soilWBase
		soilW ∈ land.pools
	end

	## calculate variables
	# if useLookUp is set to true in modelRun.json; run the original non-linear equation
	wSat = p_wSat[sl]
	θ_dos = soilW[sl] / wSat
	β = p_β[sl]
	kSat = p_kSat[sl]
	λ = 1 / β
	K = kSat * ((θ_dos) ^ (3 + (2 / λ)))
	return K
end

"""
calculates the soil hydraulic properties based on Saxton 2006

# Inputs:
 - : texture-based parameters
 - info
 - land.soilTexture.p_[CLAY/SAND]: in fraction
 - sl: soil layer to calculate property for

# Outputs:
 - hydraulic conductivity [k], matric potention [ψ] & porosity  (θ) at saturation [Sat], field capacity [FC], & wilting point  (WP)
 - properties of moisture-retention curves: (α & β)

# Modifies:
 - None

# Extended help

# References:
 - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by  texture & organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.

# Versions:
 - 1.0 on 22.11.2019 [skoirala]:

# Created by:
 - skoirala

# Notes:
 - FC: Field Capacity moisture [33 kPa], #v  
 - PAW: Plant Avail. moisture [33-1500 kPa, matric soil], #v
 - PAWB: Plant Avail. moisture [33-1500 kPa, bulk soil], #v
 - SAT: Saturation moisture [0 kPa], #v
 - WP: Wilting point moisture [1500 kPa], #v
"""
function soilParamsSaxton2006(land, infotem, sl)

	# @unpack_soilProperties_Saxton2006 o

	@unpack_land (p_CLAY, p_ORGM, p_SAND) ∈ land.soilTexture


	## calculate variables
	# Get sand; clay; & organic matter contents
	# CLAY: Clay; #w
	# SAND: Sand; #w
	# ORGM: Organic Matter; #w
	# CLAY = CLAY / 100
	# SAND = SAND / 100
	# ORGM = ORGM / 100
	# p_CLAY
	CLAY = p_CLAY[sl]
	SAND = p_SAND[sl]
	ORGM = p_ORGM[sl]
	# CLAY = CLAY
	# SAND = SAND
	# ORGM = ORGM
	## Moisture regressions
	# θ_1500t: 1500 kPa moisture; first solution; #v
	# θ_1500: 1500 kPa moisture; #v
	θ_1500t = -0.024 * SAND + 0.487 * CLAY + 0.006 * ORGM + 0.005 * (SAND * ORGM) - 0.013 * (CLAY * ORGM) + 0.068 * (SAND * CLAY) + 0.031
	θ_1500 = θ_1500t + (0.14 * θ_1500t - 0.02)
	# θ_33t: 33 kPa moisture; first solution; #v
	# θ_33: 33 kPa moisture; normal density; #v
	θ_33t = -0.251 * SAND + 0.195 * CLAY + 0.011 * ORGM + 0.006 * (SAND * ORGM) - 0.027 * (CLAY * ORGM) + 0.452 * (SAND * CLAY) + 0.299
	θ_33 = θ_33t + (1.283 * (θ_33t) ^ 2 - 0.374 * θ_33t - 0.015)
	# θ_s_33t: SAT-33 kPa moisture; first solution; #v
	# θ_s_33: SAT-33 kPa moisture; normal density #v
	θ_s_33t = 0.278 * SAND + 0.034 * CLAY + 0.022 * ORGM - 0.018 * (SAND * ORGM) - 0.027 * (CLAY * ORGM) - 0.584 * (SAND * CLAY) + 0.078
	θ_s_33 = θ_s_33t + (0.636 * θ_s_33t - 0.107)
	# ψ_et: Tension at air entry; first solution; kPa
	# ψ_e: Tension at air entry [bubbling pressure], kPa
	ψ_et = abs(-21.67 * SAND - 27.93 * CLAY - 81.97 * θ_s_33 + 71.12 * (SAND * θ_s_33) + 8.29 * (CLAY * θ_s_33)
	- 14.05 * (SAND * CLAY) + 27.16)
	ψ_e = abs(ψ_et + (0.02 * (ψ_et ^ 2) - 0.113 * ψ_et - 0.70))
	# θ_s: Saturated moisture [0 kPa], normal density, #v
	# rho_N: Normal density; g cm-3
	θ_s = θ_33 + θ_s_33 - 0.097 * SAND + 0.043
	rho_N = (1.0 - θ_s) * 2.65
	## Density effects
	# rho_DF: Adjusted density; g cm-3
	# θ_s_DF: Saturated moisture [0 kPa], adjusted density, #v
	# θ_33_DF: 33 kPa moisture; adjusted density; #v
	# θ_s_33_DF: SAT-33 kPa moisture; adjusted density; #v
	# DF: Density adjustment Factor [0.9-1.3]
	rho_DF = rho_N * DF
	# θ_s_DF = 1 - (rho_DF / 2.65); # original but does not include θ_s
	θ_s_DF = θ_s * (1.0 - (rho_DF / 2.65)); # may be includes θ_s
	θ_33_DF = θ_33 - 0.2 * (θ_s - θ_s_DF)
	θ_1500_DF = θ_1500 - 0.2 * (θ_s - θ_s_DF)
	θ_s_33_DF = θ_s_DF - θ_33_DF
	## Moisture-Tension
	# A, B: Coefficients of moisture-tension, Eq. [11]
	# ψ_θ: Tension at moisture θ; kPa
	B = (log(1500) - log(33)) / (log(θ_33) - log(θ_1500))
	A = exp(log(33) + B * log(θ_33))
	# ψ_θ = A * ((θ) ^ (-B))
	# ψ_33 = 33.0 - ((θ - θ_33) * (33.0 - ψ_e)) / (θ_s - θ_33)
	## Moisture-Conductivity
	# λ: Slope of logarithmic tension-moisture curve
	# Ks: Saturated conductivity [matric soil], mm h-1
	# K_θ: Unsaturated conductivity at moisture θ; mm h-1
	λ = 1 / B
	Ks = 1930 * ((θ_s - θ_33) ^ (3 - λ)) * 24
	# K_θ = Ks * ((θ / θ_s) ^ (3 + (2 / λ)))
	## Gravel Effects
	# rho_B: Bulk soil density [matric plus gravel], g cm-3
	# αRho: Matric soil density/gravel density [2.65] = rho/2.65
	# Rv: Volume fraction of gravel [decimal], g cm -3
	# Rw: Weight fraction of gravel [decimal], g g-1
	# Kb: Saturated conductivity [bulk soil], mm h-1
	αRho = matricSoilDensity / gravelDensity
	Rv = (αRho * Rw) / (1.0 - Rw * (1.0 - αRho))
	rho_B = rho_N * (1.0 - Rv) + Rv * 2.65
	# PAW_B = PAW * (1.0 - Rv)
	Kb = Ks * ((1.0 - Rw) / (1.0 - Rw * (1.0 - (3 * αRho / 2))))
	## Salinity Effects
	# ϕ_o: Osmotic potential at θ = θ_s; kPa
	# ϕ_o_θ: Osmotic potential at θ < θ_s; kPa
	# EC: Electrical conductance of a saturated soil extract, dS m-1 [dS/m = mili-mho cm-1]
	phi_o = 36 * EC
	# ϕ_o_θ = (θ_s / θ) * 36 / EC
	## Assign the variables for returning
	α = A
	β = B
	# θSat = θ_s_DF
	θSat = θ_s
	kSat = Kb
	ψSat = 0.0
	# θFC = θ_33_DF
	θFC = θ_33
	kFC = kSat * ((θFC / θSat) ^ (3 + (2 / λ)))
	ψFC = 33
	# θWP = θ_1500_DF
	θWP = θ_1500
	ψWP = 1500
	kWP = kSat * ((θWP / θSat) ^ (3 + (2 / λ)))

	## pack land variables
	return α, β, kSat, θSat, ψSat, kFC, θFC, ψFC, kWP, θWP, ψWP
end

