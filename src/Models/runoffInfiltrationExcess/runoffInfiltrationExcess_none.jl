export runoffInfiltrationExcess_none

struct runoffInfiltrationExcess_none <: runoffInfiltrationExcess end

function define(p_struct::runoffInfiltrationExcess_none, forcing, land, helpers)

    ## calculate variables
    inf_excess_runoff = helpers.numbers.𝟘

    ## pack land variables
    @pack_land inf_excess_runoff => land.fluxes
    return land
end

@doc """
sets infiltration excess runoff to zero

# instantiate:
instantiate/instantiate time-invariant variables for runoffInfiltrationExcess_none


---

# Extended help
"""
runoffInfiltrationExcess_none
