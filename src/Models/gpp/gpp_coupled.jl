export gpp_coupled

struct gpp_coupled <: gpp end

function compute(params::gpp_coupled, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        transpiration_supply ⇐ land.diagnostics
        gpp_f_soilW ⇐ land.diagnostics
        gpp_demand ⇐ land.diagnostics
        WUE ⇐ land.diagnostics
    end

    gpp = min(transpiration_supply * WUE, gpp_demand * gpp_f_soilW)

    ## pack land variables
    @pack_nt gpp ⇒ land.fluxes
    return land
end


purpose(::Type{gpp_coupled}) = "calculate GPP based on transpiration supply & water use efficiency [coupled]"

@doc """

$(getBaseDocString(gpp_coupled))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by*
 - mjung
 - skoirala

*Notes*
"""
gpp_coupled
