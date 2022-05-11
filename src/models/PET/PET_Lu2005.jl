export PET_Lu2005

struct PET_Lu2005 <: PET
end

function precompute(o::PET_Lu2005, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack forcing
	@unpack_forcing Tair ∈ forcing

	## calculate variables
	Tair_prev = Tair

	## pack land variables
	@pack_land Tair_prev => land.PET
	return land
end

function compute(o::PET_Lu2005, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack forcing
	@unpack_forcing (Rn, Tair) ∈ forcing
	@unpack_land Tair_prev ∈ land.PET
	@unpack_land (𝟘, sNT) ∈ helpers.numbers


	## calculate variables
	# α is the calibration constant: α = 1.26 for wet | humid
	# conditions
	α = 1.26
	# @show "Lu", sNT(1)
	# slope of the saturation vapor pressure temperature curve [kPa/°C]
	Δ = 0.200 * (0.00738 * Tair + 0.8072) ^ 7.0 - 0.000116

	# cp is the specific heat of moist air at constant pressure
	# (kJ/kg/°C) & where cp = 1.013 kJ/kg/°C = 0.0010 13 MJ/kg/°C
	cp = 0.001013
	
	# & p is the atmospheric pressure [kPa] EL = elevation
	EL = 0.0
	atmp = 101.3 - 0.01055 * EL

	# λ is the latent hear of vaporization [MJ/kg]
	λ = 2.501 - 0.002361 * Tair

	# γ is the the psychrometric constant modified by the ratio of
	# canopy resistance to atmospheric resistance [kPa/°C].
	γ = cp * atmp / (0.622 * λ)
	
	# G is the heat flux density to the ground [MJ/m^2/day]
	# G = 4.2[T[i+1]-T[i-1]]/dt → adopted to T[i]-T[i-1] by skoirala
	# G = 4.2 * (Tair_ip1 - Tair_im1) / dt
	# where Ti is the mean air temperature [°C] for the period i; &
	# dt the difference of time [days]..
	# ΔTair = Tair - Tair_prev
	# dt = 2.0
	# G = 4.2 * (ΔTair) / dt
	G = 0.0
	PET = (α * (Δ / (Δ + γ)) * (Rn - G)) / λ
	PET = max(PET, 𝟘)

	Tair_prev = Tair

	## pack land variables
	@pack_land (PET, Tair_prev) => land.PET
	return land
end

@doc """
Calculates the value of land.PET.PET from the forcing variables

---

# compute:
Set potential evapotranspiration using PET_Lu2005

*Inputs*
 - forcing.Rn: Net radiation
 - forcing.Tair: Air temperature

*Outputs*
 - land.PET.PET: the value of PET for current time step

---

# Extended help

*References*
 - Lu

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
PET_Lu2005