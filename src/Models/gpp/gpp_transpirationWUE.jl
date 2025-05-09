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

purpose(::Type{gpp_transpirationWUE}) = "calculate GPP based on transpiration & water use efficiency"

@doc """

$(getModelDocString(gpp_transpirationWUE))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2023 [skoirala | @dr-ko]

*Created by*
 - mjung
 - skoirala | @dr-ko

*Notes*
"""
gpp_transpirationWUE
