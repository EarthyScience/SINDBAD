export soilProperties_Saxton1986, kSaxton1986, soilParamsSaxton1986

@bounds @describe @units @with_kw struct soilProperties_Saxton1986{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20, T21} <: soilProperties
	ψFC::T1 = 33.0 | (30.0, 35.0) | "matric potential at field capacity" | "kPa"
	ψWP::T2 = 1500.0 | (1000.0, 1800.0) | "matric potential at wilting point" | "kPa"
	ψSat::T3 = 0.0 | (0.0, 5.0) | "matric potential at saturation" | "kPa"
	a::T4 = -4.396 | nothing | "Saxton Parameters" | ""
	b::T5 = -0.0715 | nothing | "Saxton Parameters" | ""
	c::T6 = -0.000488 | nothing | "Saxton Parameters" | ""
	d1::T7 = -4.285e-05 | nothing | "Saxton Parameters" | ""
	e::T8 = -3.14 | nothing | "Saxton Parameters" | ""
	f1::T9 = -0.00222 | nothing | "Saxton Parameters" | ""
	g::T10 = -3.484e-05 | nothing | "Saxton Parameters" | ""
	h::T11 = 0.332 | nothing | "Saxton Parameters" | ""
	j::T12 = -0.0007251 | nothing | "Saxton Parameters" | ""
	k::T13 = 0.1276 | nothing | "Saxton Parameters" | ""
	m::T14 = -0.108 | nothing | "Saxton Parameters" | ""
	n::T15 = 0.341 | nothing | "Saxton Parameters" | ""
	p::T16 = 12.012 | nothing | "Saxton Parameters" | ""
	q::T17 = -0.0755 | nothing | "Saxton Parameters" | ""
	r::T18 = -3.895 | nothing | "Saxton Parameters" | ""
	t::T19 = 0.03671 | nothing | "Saxton Parameters" | ""
	u::T20 = -0.1103 | nothing | "Saxton Parameters" | ""
	v::T21 = 0.00087546 | nothing | "Saxton Parameters" | ""
end

function precompute(o::soilProperties_Saxton1986, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_soilProperties_Saxton1986 o

	## instantiate variables
	p_α = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_β = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_kFC = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_θFC = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_ψFC = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_kWP = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_θWP = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_ψWP = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_kSat = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_θSat = ones(helpers.numbers.numType, length(land.pools.soilW))
	p_ψSat = ones(helpers.numbers.numType, length(land.pools.soilW))

	## pack land variables
	@pack_land (p_α, p_β, p_kFC, p_θFC, p_ψFC, p_kWP, p_θWP, p_ψWP, p_kSat, p_θSat, p_ψSat) => land.soilProperties
	return land
end

function compute(o::soilProperties_Saxton1986, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_soilProperties_Saxton1986 o

	## unpack land variables
	@unpack_land (p_α, p_β, p_kFC, p_θFC, p_ψFC, p_kWP, p_θWP, p_ψWP, p_kSat, p_θSat, p_ψSat) ∈ land.soilProperties

	## calculate variables
	# number of layers & creation of arrays
	# calculate & set the soil hydraulic properties for each layer
	for sl in 1:length(land.pools.soilW)
		(α, β, kFC, θFC, ψFC) = soilParamsSaxton1986(land, helpers, sl, ψFC)
		(_, _, kWP, θWP, ψWP) = soilParamsSaxton1986(land, helpers, sl, ψWP)
		(_, _, kSat, θSat, ψSat) = soilParamsSaxton1986(land, helpers, sl, ψSat)
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
	p_unsatK = kSaxton1986

	## pack land variables
	@pack_land (p_kFC, p_kSat, p_unsatK, p_kWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) => land.soilProperties
	return land
end

@doc """
assigns the soil hydraulic properties based on Saxton; 1986 to land.soilProperties.p_

# Parameters
$(PARAMFIELDS)

# precompute:
precompute/instantiate time-invariant variables for soilProperties_Saxton1986


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
		soilW ∈ land.pools
	end

	## calculate variables
	CLAY = p_CLAY[sl] * 100
	SAND = p_SAND[sl] * 100
	soilD = soilLayerThickness[sl]
	θ = soilW[sl] / soilD
	K = 2.778E-6 * (exp(p + q * SAND + (r + t * SAND + u * CLAY + v * CLAY ^ 2) * (1 / θ))) * 1000 * 3600 * 24

	## pack land variables
	return K
end

"""
calculates the soil hydraulic properties based on Saxton 1986

# Extended help
"""
function soilParamsSaxton1986(land, helpers, sl, WT)
	@unpack_land (p_CLAY, p_SAND) ∈ land.soilTexture


	## calculate variables
	# CONVERT SAND AND CLAY TO PERCENTAGES
	CLAY = p_CLAY[sl] * 100
	SAND = p_SAND[sl] * 100
	# Equations
	A = exp(a + b * CLAY + c * SAND ^ 2.0 + d1 * SAND ^ 2 * CLAY) * 100
	B = e + f1 * CLAY ^ 2.0 + g * SAND ^ 2 * CLAY
	# soil matric potential; ψ; kPa
	ψ = WT
	# soil moisture content at saturation [m^3/m^3]
	θ_s = h + j * SAND + k * log10(CLAY)
	# air entry pressure [kPa]
	ψ_e = abs(100 * (m + n * θ_s))
	θ = ones(helpers.numbers.numType, size(CLAY))
	ndx = find(ψ >= 10 & ψ <= 1500)
	if !isempty(ndx)
		θ[ndx] = (ψ[ndx] / A[ndx]) ^ (1 / B[ndx])
	end
	# clear ndx
	ndx = find(ψ >= ψ_e & ψ < 10)
	if !isempty(ndx)
		# θ at 10 kPa [m^3/m^3]
		θ_10 = exp((2.302 - log(A[ndx])) / B[ndx])
		# ---------------------------------------------------------------------
		# ψ[ndx] = 10.0 - (θ[ndx] - θ_10[ndx]) * (10.0 - # ψ_e[ndx]) / (θ_s[ndx] - θ_10[ndx])
		# ---------------------------------------------------------------------
		θ[ndx] = θ_10 + (10.0 - ψ[ndx]) * (θ_s[ndx] - θ_10) / (10.0 - ψ_e[ndx])
	end
	# clear ndx
	ndx = find(ψ >= 0.0 & ψ < ψ_e)
	if !isempty(ndx)
		θ[ndx] = θ_s[ndx]
	end
	# clear ndx
	# hydraulic conductivity [mm/day]: original equation for mm/s
	K = 2.778E-6 * (exp(p + q * SAND + (r + t * SAND + u * CLAY + v * CLAY ^ 2) * (1 / θ))) * 1000 * 3600 * 24
	α = A
	β = B

	## pack land variables
	return α, β, K, θ, ψ
end

