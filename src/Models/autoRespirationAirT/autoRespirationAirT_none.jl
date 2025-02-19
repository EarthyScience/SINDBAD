export autoRespirationAirT_none

struct autoRespirationAirT_none <: autoRespirationAirT end

function define(params::autoRespirationAirT_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    auto_respiration_f_airT = one(first(cEco))

    ## pack land variables
    @pack_nt auto_respiration_f_airT ⇒ land.diagnostics
    return land
end

@doc """
Sets the effect of temperature on the maintenance component of autotrophic respiration (RA) to one (i.e. no effect).

# Instantiate:
Instantiate time-invariant variables for autoRespirationAirT_none


---

# Extended help
"""
autoRespirationAirT_none
