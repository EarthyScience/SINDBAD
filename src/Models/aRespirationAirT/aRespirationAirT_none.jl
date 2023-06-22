export aRespirationAirT_none

struct aRespirationAirT_none <: aRespirationAirT end

function define(o::aRespirationAirT_none, forcing, land, helpers)

    ## calculate variables
    fT = helpers.numbers.𝟙

    ## pack land variables
    @pack_land fT => land.aRespirationAirT
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
