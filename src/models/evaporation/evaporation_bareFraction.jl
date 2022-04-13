export evaporation_bareFraction, evaporation_bareFraction_h
"""
calculates the bare soil evaporation from 1-vegFraction of the grid & PETsoil

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evaporation_bareFraction{T1} <: evaporation
	ks::T1 = 0.5 | (0.1, 0.95) | "resistance against soil evaporation" | ""
end

function precompute(o::evaporation_bareFraction, forcing, land, infotem)
	# @unpack_evaporation_bareFraction o
	return land
end

function compute(o::evaporation_bareFraction, forcing, land, infotem)
	@unpack_evaporation_bareFraction o

	## unpack variables
	@unpack_land begin
		vegFraction ∈ land.states
		soilW ∈ land.pools
		PET ∈ land.PET
	end
	#--> scale the potential ET with bare soil fraction
	PETsoil = PET * (1.0 - vegFraction)
	#--> calculate actual ET as a fraction of PETsoil
	evaporation = min(PETsoil, soilW[1] * ks)

	## pack variables
	@pack_land begin
		PETsoil ∋ land.evaporation
		evaporation ∋ land.fluxes
	end
	return land
end

function update(o::evaporation_bareFraction, forcing, land, infotem)
	@unpack_evaporation_bareFraction o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		evaporation ∈ land.fluxes
	end

	## update variables
	# update soil moisture of the first layer
	soilW[1] = soilW[1] - evaporation

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
calculates the bare soil evaporation from 1-vegFraction of the grid & PETsoil

# precompute:
precompute/instantiate time-invariant variables for evaporation_bareFraction

# compute:
Soil evaporation using evaporation_bareFraction

*Inputs:*
 - land.PET.PET: forcing data set
 - land.states.vegFraction [output of vegFraction module]

*Outputs:*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update
update pools and states in evaporation_bareFraction
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code & moved from prec to dyna to handle land.states.vegFraction  

*Created by:*
 - Martin Jung [mjung@]
 - Sujan Koirala [skoirala]
 - Tina Trautmann [ttraut@]
"""
function evaporation_bareFraction_h end