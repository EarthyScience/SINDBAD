export transpiration_coupled

struct transpiration_coupled <: transpiration end

function compute(params::transpiration_coupled, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        gpp ∈ land.fluxes
        WUE ∈ land.WUE
    end
    # calculate actual transpiration coupled with GPP
    transpiration = gpp / WUE

    ## pack land variables
    @pack_land transpiration => land.fluxes
    return land
end

@doc """
calculate the actual transpiration as function of gpp & WUE

---

# compute:
If coupled, computed from gpp and aoe from wue using transpiration_coupled

*Inputs*
 - land.WUE.WUE: water use efficiency in gC/mmH2O
 - land.fluxes.gpp: GPP based on a minimum of demand & stressors (except water  limitation) out of gpp_coupled in which transpiration_supply is used to get  supply limited GPP

*Outputs*
 - land.fluxes.transpiration: actual transpiration

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - mjung
 - skoirala

*Notes*
"""
transpiration_coupled
