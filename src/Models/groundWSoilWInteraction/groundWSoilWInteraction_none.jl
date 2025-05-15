export groundWSoilWInteraction_none

struct groundWSoilWInteraction_none <: groundWSoilWInteraction end

function define(params::groundWSoilWInteraction_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    gw_capillary_flux = z_zero

    ## pack land variables
    @pack_nt gw_capillary_flux ⇒ land.fluxes
    return land
end

purpose(::Type{groundWSoilWInteraction_none}) = "sets the groundwater capillary flux to zero"

@doc """

$(getModelDocString(groundWSoilWInteraction_none))

---

# Extended help
"""
groundWSoilWInteraction_none
