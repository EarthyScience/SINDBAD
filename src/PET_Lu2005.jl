export PET_Lu2005, h_PET_Lu2005
"""
Calculates the value of land.PET.PET from the forcing variables

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct PET_Lu2005{T} <: PET
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::PET_Lu2005, forcing, land, infotem)
	# @unpack_PET_Lu2005 o
	return land
end

function compute(o::PET_Lu2005, forcing, land, infotem)
	@unpack_PET_Lu2005 o

	## unpack variables
	@unpack_land begin
		(Rn, Tair) ∈ forcing
	end
	# α is the calibration constant: α = 1.26 for wet | humid
	# conditions
	α = 1.26
	# slope of the saturation vapor pressure temperature curve [kPa/°C]
	Δ = 0.200 * (0.00738 * Tair + 0.8072) ^ 7 - 0.000116
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
	# & G is the heat flux density to the ground [MJ/m^2/day]
	# G = 4.2[T[i+1]-T[i-1]]/dt
	# where Ti is the mean air temperature [°C] for the period i; &
	# dt the difference of time [days]
	# Tair_ip1 = [Tair[2:end] Tair[end]]
	# Tair_im1 = [Tair[1] Tair[1:end-1]]
	dt = 2.0
	# G = 4.2 * (Tair_ip1 - Tair_im1) / dt
	G = 0.0
	PET = (α * (Δ / (Δ + γ)) * (Rn - G)) / λ
	PET = max(PET, 0.0)

	## pack variables
	@pack_land begin
		PET ∋ land.PET
	end
	return land
end

function update(o::PET_Lu2005, forcing, land, infotem)
	# @unpack_PET_Lu2005 o
	return land
end

"""
Calculates the value of land.PET.PET from the forcing variables

# precompute:
precompute/instantiate time-invariant variables for PET_Lu2005

# compute:
Set potential evapotranspiration using PET_Lu2005

*Inputs:*
 - forcing.Rn: Net radiation
 - forcing.Tair: Air temperature

*Outputs:*
 - land.PET.PET: the value of PET for current time step

# update
update pools and states in PET_Lu2005
 -

# Extended help

*References:*
 - Lu

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function h_PET_Lu2005 end
