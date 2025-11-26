export transpiration_coupled

struct transpiration_coupled <: transpiration end

function compute(params::transpiration_coupled, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        gpp ⇐ land.fluxes
        WUE ⇐ land.diagnostics
    end
    # calculate actual transpiration coupled with GPP
    transpiration = gpp / WUE

    ## pack land variables
    @pack_nt transpiration ⇒ land.fluxes
    return land
end

purpose(::Type{transpiration_coupled}) = "Transpiration as a function of GPP and WUE."

@doc """

$(getModelDocString(transpiration_coupled))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]

*Created by*
 - mjung
 - skoirala | @dr-ko

*Notes*
"""
transpiration_coupled
