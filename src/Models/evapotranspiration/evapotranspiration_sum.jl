export evapotranspiration_sum

struct evapotranspiration_sum <: evapotranspiration
end

function precompute(o::evapotranspiration_sum, forcing, land::NamedTuple, helpers::NamedTuple)
    @unpack_land 𝟘  ∈ helpers.numbers
	
    ## set variables to zero
    evaporation = 𝟘 
    interception = 𝟘 
    sublimation = 𝟘 
    transpiration = 𝟘 

    ## pack land variables
    @pack_land begin
        (evaporation, interception, sublimation, transpiration) => land.fluxes
    end
    return land
end

function compute(o::evapotranspiration_sum, forcing, land::NamedTuple, helpers::NamedTuple)

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

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
evapotranspiration_sum