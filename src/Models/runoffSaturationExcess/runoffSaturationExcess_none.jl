export runoffSaturationExcess_none

struct runoffSaturationExcess_none <: runoffSaturationExcess end

function define(params::runoffSaturationExcess_none, forcing, land, helpers)

    ## calculate variables
    sat_excess_runoff = land.constants.z_zero

    ## pack land variables
    @pack_land sat_excess_runoff → land.fluxes
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
