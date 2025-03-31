export evapotranspiration_sum

struct evapotranspiration_sum <: evapotranspiration end

function define(params::evapotranspiration_sum, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## set variables to zero
    evaporation = z_zero
    evapotranspiration = z_zero
    interception = z_zero
    sublimation = z_zero
    transpiration = z_zero

    ## pack land variables
    @pack_nt begin
        (evaporation, evapotranspiration, interception, sublimation, transpiration) ⇒ land.fluxes
    end
    return land
end

function compute(params::evapotranspiration_sum, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt (evaporation, interception, sublimation, transpiration) ⇐ land.fluxes

    ## calculate variables
    evapotranspiration = interception + transpiration + evaporation + sublimation

    ## pack land variables
    @pack_nt evapotranspiration ⇒ land.fluxes
    return land
end

purpose(::Type{evapotranspiration_sum}) = "calculates evapotranspiration as a sum of all potential components"

@doc """

$(getBaseDocString(evapotranspiration_sum))

---

# Extended help

*References*

*Versions*
 - 1.0 on 01.04.2022  

*Created by*
 - skoirala
"""
evapotranspiration_sum
