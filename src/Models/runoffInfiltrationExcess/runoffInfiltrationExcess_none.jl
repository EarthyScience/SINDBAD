export runoffInfiltrationExcess_none

struct runoffInfiltrationExcess_none <: runoffInfiltrationExcess end

function define(params::runoffInfiltrationExcess_none, forcing, land, helpers)
    @unpack_nt z_zero ⇐ land.constants

    ## calculate variables
    inf_excess_runoff = z_zero

    ## pack land variables
    @pack_nt inf_excess_runoff ⇒ land.fluxes
    return land
end

purpose(::Type{runoffInfiltrationExcess_none}) = "Sets infiltration excess runoff to 0."

@doc """

$(getModelDocString(runoffInfiltrationExcess_none))

---

# Extended help
"""
runoffInfiltrationExcess_none
