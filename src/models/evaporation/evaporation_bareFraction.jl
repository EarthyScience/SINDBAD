export evaporation_bareFraction

@bounds @describe @units @with_kw struct evaporation_bareFraction{T1} <: evaporation
	ks::T1 = 0.5 | (0.1, 0.95) | "resistance against soil evaporation" | ""
end

function compute(o::evaporation_bareFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_evaporation_bareFraction o

	## unpack land variables
	@unpack_land begin
		vegFraction ∈ land.states
		ΔsoilW ∈ land.states
		soilW ∈ land.pools
		PET ∈ land.PET
	end
	# scale the potential ET with bare soil fraction
	PETsoil = PET * (helpers.numbers.𝟙 - vegFraction)
	# calculate actual ET as a fraction of PETsoil
	evaporation = min(PETsoil, (soilW[1] + ΔsoilW[1]) * ks)

	# update soil moisture changes
	ΔsoilW[1] = ΔsoilW[1] - evaporation

	## pack land variables
	@pack_land begin
		PETsoil => land.evaporation
		evaporation => land.fluxes
		ΔsoilW => land.states
	end
	return land
end

function update(o::evaporation_bareFraction, forcing, land, helpers)
	@unpack_evaporation_bareFraction o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end

	## update variables
	# update soil moisture of the first layer
	soilW[1] = soilW[1] + ΔsoilW[1]

	# reset soil moisture changes to zero
	ΔsoilW[1] = ΔsoilW[1] - ΔsoilW[1]

	## pack land variables
	@pack_land begin
		soilW => land.pools
		ΔsoilW => land.states
	end
	return land
end

@doc """
calculates the bare soil evaporation from 1-vegFraction of the grid & PETsoil

# Parameters
$(PARAMFIELDS)

---

# compute:
Soil evaporation using evaporation_bareFraction

*Inputs*
 - land.PET.PET: forcing data set
 - land.states.vegFraction [output of vegFraction module]

*Outputs*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update

update pools and states in evaporation_bareFraction

 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code & moved from prec to dyna to handle land.states.vegFraction  

*Created by:*
 - mjung
 - skoirala
 - ttraut
"""
evaporation_bareFraction