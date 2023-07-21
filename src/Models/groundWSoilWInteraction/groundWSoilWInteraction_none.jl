export groundWSoilWInteraction_none

struct groundWSoilWInteraction_none <: groundWSoilWInteraction end

function define(p_struct::groundWSoilWInteraction_none, forcing, land, helpers)

    ## calculate variables
    gw_capillary_flux = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land gw_capillary_flux => land.fluxes
    return land
end

@doc """
sets the groundwater capillary flux to zero

# instantiate:
instantiate/instantiate time-invariant variables for groundWSoilWInteraction_none


---

# Extended help
"""
groundWSoilWInteraction_none
