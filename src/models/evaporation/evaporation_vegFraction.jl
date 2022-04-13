export evaporation_vegFraction, evaporation_vegFraction_h
"""
calculates the bare soil evaporation from 1-vegFraction & PET soil

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evaporation_vegFraction{T1, T2} <: evaporation
	α::T1 = 1.0 | (0.0, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
	supLim::T2 = 0.2 | (0.03, 1.0) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end

function precompute(o::evaporation_vegFraction, forcing, land, infotem)
	# @unpack_evaporation_vegFraction o
	return land
end

function compute(o::evaporation_vegFraction, forcing, land, infotem)
	@unpack_evaporation_vegFraction o

	## unpack variables
	@unpack_land begin
		vegFraction ∈ land.states
		soilW ∈ land.pools
		PET ∈ land.PET
	end
	#--> multiply equilibrium PET with αSoil & [1.0 - vegFraction] to get potential soil evap
	tmp = PET * α * (1.0 - vegFraction)
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

function update(o::evaporation_vegFraction, forcing, land, infotem)
	@unpack_evaporation_vegFraction o

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
calculates the bare soil evaporation from 1-vegFraction & PET soil

# precompute:
precompute/instantiate time-invariant variables for evaporation_vegFraction

# compute:
Soil evaporation using evaporation_vegFraction

*Inputs:*
 - land.PET.PET: forcing data set
 - land.states.vegFraction [output of vegFraction module]
 - α

*Outputs:*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update
update pools and states in evaporation_vegFraction
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
function evaporation_vegFraction_h end