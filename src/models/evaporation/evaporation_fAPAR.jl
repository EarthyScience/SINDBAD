export evaporation_fAPAR, evaporation_fAPAR_h
"""
calculates the bare soil evaporation from 1-fAPAR & PET soil

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evaporation_fAPAR{T1, T2} <: evaporation
	α::T1 = 1.0 | (0.1, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
	supLim::T2 = 0.2 | (0.05, 1.0) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end

function precompute(o::evaporation_fAPAR, forcing, land, infotem)
	# @unpack_evaporation_fAPAR o
	return land
end

function compute(o::evaporation_fAPAR, forcing, land, infotem)
	@unpack_evaporation_fAPAR o

	## unpack variables
	@unpack_land begin
		fAPAR ∈ land.states
		soilW ∈ land.pools
		PET ∈ land.PET
	end
	#--> multiply equilibrium PET with αSoil & [1.0 - fAPAR] to get potential soil evap
	tmp = PET * α * (1.0 - fAPAR)
	tmp[tmp < 0.0] = 0.0
	PETsoil = tmp
	#--> scale the potential with the a fraction of available water & get the minimum of the current moisture
	evaporation = min(PETsoil, supLim * soilW[1])

	## pack variables
	@pack_land begin
		PETsoil ∋ land.evaporation
		evaporation ∋ land.fluxes
	end
	return land
end

function update(o::evaporation_fAPAR, forcing, land, infotem)
	@unpack_evaporation_fAPAR o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		evaporation ∈ land.fluxes
	end

	## update variables
	#--> update soil moisture of the uppermost soil layer
	soilW[1] = soilW[1] - evaporation

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
calculates the bare soil evaporation from 1-fAPAR & PET soil

# precompute:
precompute/instantiate time-invariant variables for evaporation_fAPAR

# compute:
Soil evaporation using evaporation_fAPAR

*Inputs:*
 - land.PET.PET: forcing data set
 - land.states.fAPAR [output of fAPAR module]
 - α

*Outputs:*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update
update pools and states in evaporation_fAPAR
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code & moved from prec to dyna to handle land.states.vegFraction  

*Created by:*
 - Martin Jung [mjung]
 - Sujan Koirala [skoirala]
"""
function evaporation_fAPAR_h end