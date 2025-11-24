export gpp_min

struct gpp_min <: gpp end

function compute(params::gpp_min, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        gpp_f_climate ⇐ land.diagnostics
        fAPAR ⇐ land.states
        gpp_potential ⇐ land.diagnostics
        gpp_f_soilW ⇐ land.diagnostics
    end

    AllScGPP = min(gpp_f_climate, gpp_f_soilW)
    # & multiply
    gpp = fAPAR * gpp_potential * AllScGPP

    ## pack land variables
    @pack_nt begin
        gpp ⇒ land.fluxes
        AllScGPP ⇒ land.gpp
    end
    return land
end

purpose(::Type{gpp_min}) = "GPP with potential scaled by the minimum stress scalar of demand and supply for uncoupled model structures."

@doc """

$(getProcessDocstring(gpp_min))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation & clean up  

*Created by*
 - ncarvalhais

*Notes*
"""
gpp_min
