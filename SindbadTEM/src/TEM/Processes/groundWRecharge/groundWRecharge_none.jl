export groundWRecharge_none

struct groundWRecharge_none <: groundWRecharge end

function define(params::groundWRecharge_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    gw_recharge = z_zero

    ## pack land variables
    @pack_nt gw_recharge ⇒ land.fluxes
    return land
end

purpose(::Type{groundWRecharge_none}) = "Sets groundwater recharge to 0."

@doc """

$(getModelDocString(groundWRecharge_none))

---

# Extended help
"""
groundWRecharge_none
