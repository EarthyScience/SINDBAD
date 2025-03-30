export gpp_none

struct gpp_none <: gpp end

function define(params::gpp_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    gpp = z_zero

    ## pack land variables
    @pack_nt gpp ⇒ land.fluxes
    return land
end

purpose(::Type{gpp_none}) = "sets the actual GPP to zero"

@doc """

$(getBaseDocString(gpp_none))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by*
 - ncarvalhais
"""
gpp_none
