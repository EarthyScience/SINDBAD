export evaporation_demandSupply, evaporation_demandSupply_h
"""
calculates the bare soil evaporation from demand-supply limited approach. calculates the bare soil evaporation from the grid using PET & supply limit

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evaporation_demandSupply{T1, T2} <: evaporation
	α::T1 = 1.0 | (0.1, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
	supLim::T2 = 0.2 | (0.05, 1.0) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end

function precompute(o::evaporation_demandSupply, forcing, land, infotem)
	# @unpack_evaporation_demandSupply o
	return land
end

function compute(o::evaporation_demandSupply, forcing, land, infotem)
	@unpack_evaporation_demandSupply o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		PET ∈ land.PET
	end
	# calculate potential soil evaporation
	PETsoil = max(0.0, PET * α)
	#--> calculate the soil evaporation as a fraction of scaling parameter & PET
	evaporation = min(PETsoil, supLim * soilW[1])

	## pack variables
	@pack_land begin
		PETsoil ∋ land.evaporation
		evaporation ∋ land.fluxes
	end
	return land
end

function update(o::evaporation_demandSupply, forcing, land, infotem)
	@unpack_evaporation_demandSupply o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		evaporation ∈ land.fluxes
	end

	## update variables
	#--> update soil moisture of the first layer
	soilW[1] = soilW[1] - evaporation

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
calculates the bare soil evaporation from demand-supply limited approach. calculates the bare soil evaporation from the grid using PET & supply limit

# precompute:
precompute/instantiate time-invariant variables for evaporation_demandSupply

# compute:
Soil evaporation using evaporation_demandSupply

*Inputs:*
 - land.PET.PET: extra forcing from prec
 - land.evaporation.PETsoil: extra forcing from prec
 - α:

*Outputs:*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update
update pools and states in evaporation_demandSupply
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

# Extended help

*References:*
 - Teuling et al.

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code
 - 1.0 on 11.11.2019 [skoirala]: clean up the code  

*Created by:*
 - Martin Jung [mjung@]
 - Sujan Koirala [skoirala]
 - Tina Trautmann [ttraut@]

*Notes:*
 - considers that the soil evaporation can occur from the whole grid & not only the  non-vegetated fraction of the grid cell  
"""
function evaporation_demandSupply_h end