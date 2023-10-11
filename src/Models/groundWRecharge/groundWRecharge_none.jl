export groundWRecharge_none

struct groundWRecharge_none <: groundWRecharge end

function define(params::groundWRecharge_none, forcing, land, helpers)

    ## calculate variables
    gw_recharge = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land gw_recharge => land.fluxes
    return land
end

@doc """
sets the GW recharge to zero

# instantiate:
instantiate/instantiate time-invariant variables for groundWRecharge_none


---

# Extended help
"""
groundWRecharge_none
