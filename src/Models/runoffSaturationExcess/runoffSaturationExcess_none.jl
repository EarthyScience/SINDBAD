export runoffSaturationExcess_none

struct runoffSaturationExcess_none <: runoffSaturationExcess end

function define(p_struct::runoffSaturationExcess_none, forcing, land, helpers)

    ## calculate variables
    sat_excess_runoff = helpers.numbers.𝟘

    ## pack land variables
    @pack_land sat_excess_runoff => land.fluxes
    return land
end

@doc """
set the saturation excess runoff to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffSaturationExcess_none


---

# Extended help
"""
runoffSaturationExcess_none
