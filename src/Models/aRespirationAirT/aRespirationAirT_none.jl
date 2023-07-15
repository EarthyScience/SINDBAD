export aRespirationAirT_none

struct aRespirationAirT_none <: aRespirationAirT end

function define(p_struct::aRespirationAirT_none, forcing, land, helpers)

    ## calculate variables
    auto_respiration_f_airT = one(first(land.pools.cEco))

    ## pack land variables
    @pack_land auto_respiration_f_airT => land.aRespirationAirT
    return land
end

@doc """
sets the effect of temperature on RA to one [no effect]

# instantiate:
instantiate/instantiate time-invariant variables for aRespirationAirT_none


---

# Extended help
"""
aRespirationAirT_none
