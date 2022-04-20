export evapotranspiration_sum

struct evapotranspiration_sum <: evapotranspiration
end

function precompute(o::evapotranspiration_sum, forcing, land, infotem)

	## set variables to zeros
	evaporation = infotem.helpers.zero
	interception = infotem.helpers.zero
	sublimation = infotem.helpers.zero
	transpiration = infotem.helpers.zero

	## pack land variables
	@pack_land begin
		(evaporation, interception, sublimation, transpiration) => land.fluxes
	end
	return land
end

function compute(o::evapotranspiration_sum, forcing, land, infotem)

	## unpack land variables
	@unpack_land (evaporation, interception, sublimation, transpiration) ∈ land.fluxes


	## calculate variables
	evapotranspiration = interception + transpiration + evaporation + sublimation

	## pack land variables
	@pack_land evapotranspiration => land.fluxes
	return land
end

@doc """
calculates evapotranspiration as a sum of all potential components

---

# compute:
Calculate the evapotranspiration as a sum of components using evapotranspiration_sum

*Inputs*
 - land.fluxes.evaporation
 - land.fluxes.interception
 - land.fluxes.sublimation
 - land.fluxes.transpiration

*Outputs*
 - land.fluxes.evapotranspiration

# precompute:
precompute/instantiate time-invariant variables for evapotranspiration_sum


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
evapotranspiration_sum