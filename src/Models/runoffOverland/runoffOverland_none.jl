export runoffOverland_none

struct runoffOverland_none <: runoffOverland end

function define(p_struct::runoffOverland_none, forcing, land, helpers)

    ## calculate variables
    overland_runoff = helpers.numbers.𝟘

    ## pack land variables
    @pack_land overland_runoff => land.fluxes
    return land
end

@doc """
sets overland runoff to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffOverland_none


---

# Extended help
"""
runoffOverland_none
