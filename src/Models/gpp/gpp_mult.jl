export gpp_mult

struct gpp_mult <: gpp end

function define(params::gpp_mult, forcing, land, helpers)
    @unpack_nt begin
        z_zero ⇐ land.constants
    end

    AllScGPP = z_zero
    gpp = z_zero
    ## pack land variables
    @pack_nt begin
        AllScGPP ⇒ land.gpp
        gpp ⇒ land.fluxes
    end
    return land
end

function compute(params::gpp_mult, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        gpp_f_climate ⇐ land.diagnostics
        fAPAR ⇐ land.states
        gpp_potential ⇐ land.diagnostics
        gpp_f_soilW ⇐ land.diagnostics
    end

    AllScGPP = gpp_f_climate * gpp_f_soilW #sujan

    gpp = fAPAR * gpp_potential * AllScGPP

    ## pack land variables
    @pack_nt begin
        gpp ⇒ land.fluxes
        AllScGPP ⇒ land.gpp
    end
    return land
end

purpose(::Type{gpp_mult}) = "compute the actual GPP with potential scaled by multiplicative stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]"

@doc """

$(getBaseDocString(gpp_mult))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarvalhais

*Notes*
"""
gpp_mult
