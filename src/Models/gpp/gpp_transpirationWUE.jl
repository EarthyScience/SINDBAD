export gpp_transpirationWUE

struct gpp_transpirationWUE <: gpp end

function compute(params::gpp_transpirationWUE, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        transpiration ⇐ land.fluxes
        WUE ⇐ land.diagnostics
    end

    gpp = transpiration * WUE

    ## pack land variables
    @pack_nt gpp ⇒ land.fluxes
    return land
end

@doc """
calculate GPP based on transpiration & water use efficiency

---

# compute:

*Inputs*
 - land.diagnostics.WUE: water use efficiency in gC/mmH2O
 - land.fluxes.transpiration: actual transpiration

*Outputs*
 - land.fluxes.gpp: actual GPP [gC/m2/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2023 [skoirala]

*Created by:*
 - mjung
 - skoirala

*Notes*
"""
gpp_transpirationWUE
