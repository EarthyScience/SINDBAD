export soilProperties_Saxton1986, kSaxton1986, soilParamsSaxton1986

@bounds @describe @units @with_kw struct soilProperties_Saxton1986{T1, T2, T3, TN} <: soilProperties
	ψFC::T1 = 33.0 | (30.0, 35.0) | "matric potential at field capacity" | "kPa"
	ψWP::T2 = 1500.0 | (1000.0, 1800.0) | "matric potential at wilting point" | "kPa"
	ψSat::T3 = 0.0 | (0.0, 5.0) | "matric potential at saturation" | "kPa"
	a1::TN = -4.396 | (nothing, nothing) | "Saxton Parameters" | ""
	a2::TN = -0.0715 | (nothing, nothing) | "Saxton Parameters" | ""
	a3::TN = -0.000488 | (nothing, nothing) | "Saxton Parameters" | ""
	a4::TN = -4.285e-05 | (nothing, nothing) | "Saxton Parameters" | ""
	b1::TN = -3.14 | (nothing, nothing) | "Saxton Parameters" | ""
	b2::TN = -0.00222 | (nothing, nothing) | "Saxton Parameters" | ""
	b3::TN = -3.484e-05 | (nothing, nothing) | "Saxton Parameters" | ""
	c1::TN = 0.332 | (nothing, nothing) | "Saxton Parameters" | ""
	c2::TN = -0.0007251 | (nothing, nothing) | "Saxton Parameters" | ""
	c3::TN = 0.1276 | (nothing, nothing) | "Saxton Parameters" | ""
	d1::TN = -0.108 | (nothing, nothing) | "Saxton Parameters" | ""
	d2::TN = 0.341 | (nothing, nothing) | "Saxton Parameters" | ""
	e1::TN = 2.778e-6 | (nothing, nothing) | "Saxton Parameters" | ""
	e2::TN = 12.012 | (nothing, nothing) | "Saxton Parameters" | ""
	e3::TN = -0.0755 | (nothing, nothing) | "Saxton Parameters" | ""
	e4::TN = -3.895 | (nothing, nothing) | "Saxton Parameters" | ""
	e5::TN = 0.03671 | (nothing, nothing) | "Saxton Parameters" | ""
	e6::TN = -0.1103 | (nothing, nothing) | "Saxton Parameters" | ""
	e7::TN = 0.00087546 | (nothing, nothing) | "Saxton Parameters" | ""
	f1::TN = 2.302 | (nothing, nothing) | "Saxton Parameters" | ""
	n2::TN = 2.0 | (nothing, nothing) | "Saxton Parameters" | ""
	n24::TN = 24.0 | (nothing, nothing) | "Saxton Parameters" | ""
	n10::TN = 10.0 | (nothing, nothing) | "Saxton Parameters" | ""
	n100::TN = 100.0 | (nothing, nothing) | "Saxton Parameters" | ""
	n1000::TN = 1000.0 | (nothing, nothing) | "Saxton Parameters" | ""
	n1500::TN = 1000.0 | (nothing, nothing) | "Saxton Parameters" | ""
	n3600::TN = 3600.0 | (nothing, nothing) | "Saxton Parameters" | ""

end

function instantiate(o::soilProperties_Saxton1986, forcing, land, helpers)
	@unpack_soilProperties_Saxton1986 o

	## instantiate variables
	p_α = zero(land.pools.soilW)
	p_β = zero(land.pools.soilW)
	p_kFC = zero(land.pools.soilW)
	p_θFC = zero(land.pools.soilW)
	p_ψFC = zero(land.pools.soilW)
	p_kWP = zero(land.pools.soilW)
	p_θWP = zero(land.pools.soilW)
	p_ψWP = zero(land.pools.soilW)
	p_kSat = zero(land.pools.soilW)
	p_θSat = zero(land.pools.soilW)
	p_ψSat = zero(land.pools.soilW)

	p_unsatK = kSaxton1986::typeof(kSaxton1986)

	## pack land variables
	@pack_land begin
		(p_kFC, p_kSat, p_unsatK, p_kWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) => land.soilProperties
		(n100, n1000, n2, n24, n3600, e1, e2, e3, e4, e5, e6, e7) => land.soilProperties
	end
	return land
end

function precompute(o::soilProperties_Saxton1986, forcing, land, helpers)
	## unpack parameters
	@unpack_soilProperties_Saxton1986 o

	## unpack land variables
	@unpack_land (p_α, p_β, p_kFC, p_θFC, p_ψFC, p_kWP, p_θWP, p_ψWP, p_kSat, p_θSat, p_ψSat) ∈ land.soilProperties

	## calculate variables
	# number of layers & creation of arrays
	# calculate & set the soil hydraulic properties for each layer
	for sl in eachindex(land.pools.soilW)
		(α, β, kFC, θFC, ψFC) = calcPropsSaxton1986(o, land, helpers, sl, ψFC)
		(_, _, kWP, θWP, ψWP) = calcPropsSaxton1986(o, land, helpers, sl, ψWP)
		(_, _, kSat, θSat, ψSat) = calcPropsSaxton1986(o, land, helpers, sl, ψSat)
		@rep_elem α => (p_α, sl, :soilW)
		@rep_elem β => (p_β, sl, :soilW)
		@rep_elem kFC => (p_kFC, sl, :soilW)
		@rep_elem θFC => (p_θFC, sl, :soilW)
		@rep_elem ψFC => (p_ψFC, sl, :soilW)
		@rep_elem kWP => (p_kWP, sl, :soilW)
		@rep_elem θWP => (p_θWP, sl, :soilW)
		@rep_elem ψWP => (p_ψWP, sl, :soilW)
		@rep_elem kSat => (p_kSat, sl, :soilW)
		@rep_elem θSat => (p_θSat, sl, :soilW)
		@rep_elem ψSat => (p_ψSat, sl, :soilW)
	end

	## pack land variables
	@pack_land begin
		(p_kFC, p_kSat, p_unsatK, p_kWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) => land.soilProperties
	end
	return land
end

@doc """
assigns the soil hydraulic properties based on Saxton; 1986 to land.soilProperties.p_

# Parameters
$(PARAMFIELDS)

# instantiate:
instantiate/instantiate time-invariant variables for soilProperties_Saxton1986


---

# Extended help
"""
soilProperties_Saxton1986

"""
calculates the soil hydraulic conductivity for a given moisture based on Saxton; 1986

# Extended help
"""
function kSaxton1986(land, helpers, sl)
	@unpack_land begin
		(p_CLAY, p_SAND, soilLayerThickness) ∈ land.soilWBase
		(n100, n1000, n2, n24, n3600, e1, e2, e3, e4, e5, e6, e7) ∈ land.soilProperties
		soilW ∈ land.pools
	end

	## calculate variables
	CLAY = p_CLAY[sl] * n100
	SAND = p_SAND[sl] * n100
	soilD = soilLayerThickness[sl]
	θ = soilW[sl] / soilD
	K = e1 * (exp(e2 + e3 * SAND + (e4 + e5 * SAND + e6 * CLAY + e7 * CLAY ^ n2) * (𝟙 / θ))) * n1000 * n3600 * n24

	## pack land variables
	return K
end

"""
calculates the soil hydraulic properties based on Saxton 1986

# Extended help
"""
function calcPropsSaxton1986(o::soilProperties_Saxton1986, land, helpers, sl, WT)
	@unpack_soilProperties_Saxton1986 o

	@unpack_land begin
        (𝟘, 𝟙) ∈ helpers.numbers
		(p_CLAY, p_SAND) ∈ land.soilTexture
	end

	## calculate variables
	# CONVERT SAND AND CLAY TO PERCENTAGES
	CLAY = p_CLAY[sl] * n100
	SAND = p_SAND[sl] * n100
	# Equations
	A = exp(a1 + a2 * CLAY + a3 * SAND ^ n2 + a4 * SAND ^ n2 * CLAY) * n100
	B = b1 + b2 * CLAY ^ n2 + b3 * SAND ^ n2 * CLAY
	# soil matric potential; ψ; kPa
	ψ = WT
	# soil moisture content at saturation [m^3/m^3]
	θ_s = c1 + c2 * SAND + c3 * log10(CLAY)
	# air entry pressure [kPa]
	ψ_e = abs(n100 * (d1 + d2 * θ_s))
	# θ = ones(typeof(CLAY), size(CLAY))
	θ = 𝟙
	if (ψ >= n10 & ψ <= n1500)
		θ = ψ / A ^ (𝟙 / B)
	end
	# clear ndx
	if (ψ >= ψ_e & ψ < n10)
		# θ at 10 kPa [m^3/m^3]
		θ_10 = exp((f1 - log(A)) / B)
		# ---------------------------------------------------------------------
		# ψ = 10.0 - (θ - θ_10) * (10.0 - # ψ_e) / (θ_s - θ_10)
		# ---------------------------------------------------------------------
		θ = θ_10 + (n10 - ψ) * (θ_s - θ_10) / (n10 - ψ_e)
	end
	# clear ndx
 	if (ψ >= 𝟘 & ψ < ψ_e)
		θ = θ_s
	end
	# clear ndx
	# hydraulic conductivity [mm/day]: original equation for mm/s
	K = e1 * (exp(e2 + e3 * SAND + (e4 + e5 * SAND + e6 * CLAY + e7 * CLAY ^ n2) * (𝟙 / θ))) * n1000 * n3600 * n24
	α = A
	β = B
	## pack land variables
	return α, β, K, θ, ψ
end

