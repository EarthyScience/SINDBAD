export cFlowVegProperties_none

struct cFlowVegProperties_none <: cFlowVegProperties end

function define(o::cFlowVegProperties_none, forcing, land, helpers)

    @unpack_land taker ∈ land.cCycleBase

    ## calculate variables
    p_E = helpers.numbers.sNT.(zero([taker...]))
    p_F = helpers.numbers.sNT.(zero([taker...]))

    ## pack land variables
    @pack_land (p_E, p_F) => land.cFlowVegProperties
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# instantiate:
instantiate/instantiate time-invariant variables for cFlowVegProperties_none


---

# Extended help
"""
cFlowVegProperties_none
