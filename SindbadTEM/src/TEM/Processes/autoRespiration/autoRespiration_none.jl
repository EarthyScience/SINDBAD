export autoRespiration_none

struct autoRespiration_none <: autoRespiration end

function define(params::autoRespiration_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_efflux = zero(cEco)

    ## pack land variables
    @pack_nt c_eco_efflux ⇒ land.states
    return land
end

purpose(::Type{autoRespiration_none}) = "Sets autotrophic respiration fluxes to 0."
@doc """
    $(getModelDocString(autoRespiration_none))

---
# Extended help
*Notes*
Applicability: no C cycle; or computing/inputing NPP directly, e.g. like in Potter et al., (1993) and follow up approaches.

*References*
https://doi.org/10.1029/93GB02725

"""
autoRespiration_none
