export evapotranspiration_sum

struct evapotranspiration_sum <: evapotranspiration end

function define(params::evapotranspiration_sum, forcing, land, helpers)
    @unpack_land z_zero ∈ land.wCycleBase

    ## set variables to zero
    evaporation = z_zero
    evapotranspiration = z_zero
    interception = z_zero
    sublimation = z_zero
    transpiration = z_zero

    ## pack land variables
    @pack_land begin
        (evaporation, evapotranspiration, interception, sublimation, transpiration) => land.fluxes
    end
    return land
end

function compute(params::evapotranspiration_sum, forcing, land, helpers)

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

# instantiate:
instantiate/instantiate time-invariant variables for evapotranspiration_sum


---

# Extended help

*References*

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
evapotranspiration_sum
