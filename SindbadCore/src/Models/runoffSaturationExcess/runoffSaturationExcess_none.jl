export runoffSaturationExcess_none

struct runoffSaturationExcess_none <: runoffSaturationExcess end

function define(params::runoffSaturationExcess_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    sat_excess_runoff = z_zero

    ## pack land variables
    @pack_nt sat_excess_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffSaturationExcess_none}) = "Sets saturation excess runoff to 0."

@doc """

$(getModelDocString(runoffSaturationExcess_none))

---

# Extended help
"""
runoffSaturationExcess_none
