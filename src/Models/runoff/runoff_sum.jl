export runoff_sum

struct runoff_sum <: runoff end

function define(params::runoff_sum, forcing, land, helpers)

    @unpack_nt z_zero ⇐ land.constants

    ## set variables to zero
    base_runoff = z_zero
    runoff = z_zero
    surface_runoff = z_zero

    ## pack land variables
    @pack_nt begin
        (runoff, base_runoff, surface_runoff) ⇒ land.fluxes
    end
    return land
end

function compute(params::runoff_sum, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt (base_runoff, surface_runoff) ⇐ land.fluxes

    ## calculate variables
    runoff = surface_runoff + base_runoff

    ## pack land variables
    @pack_nt runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoff_sum}) = "calculates runoff as a sum of all potential components"

@doc """

$(getBaseDocString(runoff_sum))

---

# Extended help

*References*

*Versions*
 - 1.0 on 01.04.2022  

*Created by*
 - skoirala | @dr-ko
"""
runoff_sum
