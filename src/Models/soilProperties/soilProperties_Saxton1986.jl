export soilProperties_Saxton1986, kSaxton1986, soilParamsSaxton1986

@bounds @describe @units @with_kw struct soilProperties_Saxton1986{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20, T21} <: soilProperties
	ψFC::T1 = 33.0f0 | (30.0f0, 35.0f0) | "matric potential at field capacity" | "kPa"
	ψWP::T2 = 1500.0f0 | (1000.0f0, 1800.0f0) | "matric potential at wilting point" | "kPa"
	ψSat::T3 = 0.0f0 | (0.0f0, 5.0f0) | "matric potential at saturation" | "kPa"
	a::T4 = -4.396f0 | nothing | "Saxton Parameters" | ""
	b::T5 = -0.0715f0 | nothing | "Saxton Parameters" | ""
	c::T6 = -0.000488f0 | nothing | "Saxton Parameters" | ""
	d1::T7 = -4.285f-05 | nothing | "Saxton Parameters" | ""
	e::T8 = -3.14f0 | nothing | "Saxton Parameters" | ""
	f1::T9 = -0.00222f0 | nothing | "Saxton Parameters" | ""
	g::T10 = -3.484f-05 | nothing | "Saxton Parameters" | ""
	h::T11 = 0.332f0 | nothing | "Saxton Parameters" | ""
	j::T12 = -0.0007251f0 | nothing | "Saxton Parameters" | ""
	k::T13 = 0.1276f0 | nothing | "Saxton Parameters" | ""
	m::T14 = -0.108f0 | nothing | "Saxton Parameters" | ""
	n::T15 = 0.341f0 | nothing | "Saxton Parameters" | ""
	p::T16 = 12.012f0 | nothing | "Saxton Parameters" | ""
	q::T17 = -0.0755f0 | nothing | "Saxton Parameters" | ""
	r::T18 = -3.895f0 | nothing | "Saxton Parameters" | ""
	t::T19 = 0.03671f0 | nothing | "Saxton Parameters" | ""
	u::T20 = -0.1103f0 | nothing | "Saxton Parameters" | ""
	v::T21 = 0.00087546f0 | nothing | "Saxton Parameters" | ""
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
	for sl in eachindex(land.pools.soilW)
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
	CLAY = p_CLAY[sl] * 100f0
	SAND = p_SAND[sl] * 100f0
	soilD = soilLayerThickness[sl]
	θ = soilW[sl] / soilD
	K = 2.778f-6 * (exp(p + q * SAND + (r + t * SAND + u * CLAY + v * CLAY ^ 2) * (1 / θ))) * 1000 * 3600 * 24

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
	CLAY = p_CLAY[sl] * 100f0
	SAND = p_SAND[sl] * 100f0
	# Equations
	A = exp(a + b * CLAY + c * SAND ^ 2.0f0 + d1 * SAND ^ 2f0 * CLAY) * 100f0
	B = e + f1 * CLAY ^ 2.0f0 + g * SAND ^ 2f0 * CLAY
	# soil matric potential; ψ; kPa
	ψ = WT
	# soil moisture content at saturation [m^3/m^3]
	θ_s = h + j * SAND + k * log10(CLAY)
	# air entry pressure [kPa]
	ψ_e = abs(100f0 * (m + n * θ_s))
	θ = ones(typeof(CLAY), size(CLAY))
	ndx = find(ψ >= 10f0 & ψ <= 1500f0)
	if !isempty(ndx)
		θ[ndx] = (ψ[ndx] / A[ndx]) ^ (1 / B[ndx])
	end
	# clear ndx
	ndx = find(ψ >= ψ_e & ψ < 10f0)
	if !isempty(ndx)
		# θ at 10 kPa [m^3/m^3]
		θ_10 = exp((2.302f0 - log(A[ndx])) / B[ndx])
		# ---------------------------------------------------------------------
		# ψ[ndx] = 10.0 - (θ[ndx] - θ_10[ndx]) * (10.0 - # ψ_e[ndx]) / (θ_s[ndx] - θ_10[ndx])
		# ---------------------------------------------------------------------
		θ[ndx] = θ_10 + (10.0f0 - ψ[ndx]) * (θ_s[ndx] - θ_10) / (10.0f0 - ψ_e[ndx])
	end
	# clear ndx
	ndx = find(ψ >= 0.0f0 & ψ < ψ_e)
	if !isempty(ndx)
		θ[ndx] = θ_s[ndx]
	end
	# clear ndx
	# hydraulic conductivity [mm/day]: original equation for mm/s
	K = 2.778f-6 * (exp(p + q * SAND + (r + t * SAND + u * CLAY + v * CLAY ^ 2) * (1 / θ))) * 1000 * 3600 * 24
	α = A
	β = B

	## pack land variables
	return α, β, K, θ, ψ
end

