export PET_PriestleyTaylor1972, PET_PriestleyTaylor1972_h
"""
Calculates the value of land.PET.PET from the forcing variables

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct PET_PriestleyTaylor1972{T} <: PET
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::PET_PriestleyTaylor1972, forcing, land, infotem)
	# @unpack_PET_PriestleyTaylor1972 o
	return land
end

function compute(o::PET_PriestleyTaylor1972, forcing, land, infotem)
	@unpack_PET_PriestleyTaylor1972 o

	## unpack variables
	@unpack_land begin
		(Rn, Tair) ∈ forcing
	end
	Δ = 6.11 * exp(17.26938818 * Tair / (237.3 + Tair));
	Lhv = (5.147 * exp(-0.0004643 * Tair) - 2.6466); # MJ kg-1
	γ = 0.4 / 0.622; # hPa C-1 [psychometric constant]
	PET = 1.26 * Δ / (Δ + γ) * Rn / Lhv
	PET[PET < 0.0] = 0.0

	## pack variables
	@pack_land begin
		PET ∋ land.PET
	end
	return land
end

function update(o::PET_PriestleyTaylor1972, forcing, land, infotem)
	# @unpack_PET_PriestleyTaylor1972 o
	return land
end

"""
Calculates the value of land.PET.PET from the forcing variables

# precompute:
precompute/instantiate time-invariant variables for PET_PriestleyTaylor1972

# compute:
Set potential evapotranspiration using PET_PriestleyTaylor1972

*Inputs:*
 - forcing.Rn: Net radiation
 - forcing.Tair: Air temperature

*Outputs:*
 - land.PET.PET: the value of PET for current time step

# update
update pools and states in PET_PriestleyTaylor1972
 -

# Extended help

*References:*
 - Priestley, C. H. B., & TAYLOR, R. J. (1972). On the assessment of surface heat  flux & evaporation using large-scale parameters.  Monthly weather review, 100[2], 81-92.

*Versions:*
 - 1.0 on 20.03.2020 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function PET_PriestleyTaylor1972_h end