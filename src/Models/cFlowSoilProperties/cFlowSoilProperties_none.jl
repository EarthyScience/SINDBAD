export cFlowSoilProperties_none

struct cFlowSoilProperties_none <: cFlowSoilProperties end

function define(o::cFlowSoilProperties_none, forcing, land, helpers)
    @unpack_land taker ∈ land.cCycleBase

    ## calculate variables
    p_E = helpers.numbers.sNT.(zero([taker...]))
    p_F = helpers.numbers.sNT.(zero([taker...]))

    ## pack land variables
    @pack_land (p_E, p_F) => land.cFlowSoilProperties
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# instantiate:
instantiate/instantiate time-invariant variables for cFlowSoilProperties_none


---

# Extended help
"""
cFlowSoilProperties_none
