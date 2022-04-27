export evaporation_vegFraction

@bounds @describe @units @with_kw struct evaporation_vegFraction{T1, T2} <: evaporation
	α::T1 = 1.0 | (0.0, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
	supLim::T2 = 0.2 | (0.03, 1.0) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end

function compute(o::evaporation_vegFraction, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_evaporation_vegFraction o

	## unpack land variables
	@unpack_land begin
		vegFraction ∈ land.states
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		PET ∈ land.PET
		(𝟘, 𝟙) ∈ helpers.numbers
	end

	# multiply equilibrium PET with αSoil & [1.0 - vegFraction] to get potential soil evap
	tmp = PET * α * (𝟙 - vegFraction)
	PETsoil = max(tmp, 𝟘)

	# scale the potential with the a fraction of available water & get the minimum of the current moisture
	evaporation = min(PETsoil, supLim * (soilW[1] + ΔsoilW[1]))

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

function update(o::evaporation_vegFraction, forcing, land::NamedTuple, helpers::NamedTuple)
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
calculates the bare soil evaporation from 1-vegFraction & PET soil

# Parameters
$(PARAMFIELDS)

---

# compute:
Soil evaporation using evaporation_vegFraction

*Inputs*
 - land.PET.PET: forcing data set
 - land.states.vegFraction [output of vegFraction module]
 - α

*Outputs*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update

update pools and states in evaporation_vegFraction

 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code & moved from prec to dyna to handle land.states.vegFraction  

*Created by:*
 - mjung
 - skoirala
"""
evaporation_vegFraction