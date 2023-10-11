export autoRespirationAirT_none

struct autoRespirationAirT_none <: autoRespirationAirT end

function define(params::autoRespirationAirT_none, forcing, land, helpers)

    ## calculate variables
    auto_respiration_f_airT = one(first(land.pools.cEco))

    ## pack land variables
    @pack_land auto_respiration_f_airT => land.autoRespirationAirT
    return land
end

@doc """
sets the effect of temperature on RA to one [no effect]

# instantiate:
instantiate/instantiate time-invariant variables for autoRespirationAirT_none


---

# Extended help
"""
autoRespirationAirT_none
