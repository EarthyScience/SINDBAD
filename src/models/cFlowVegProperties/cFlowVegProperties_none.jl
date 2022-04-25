export cFlowVegProperties_none

struct cFlowVegProperties_none <: cFlowVegProperties
end

function precompute(o::cFlowVegProperties_none, forcing, land, helpers)

    ## calculate variables
    p_E = repeat(zeros(helpers.numbers.numType, length(land.pools.cEco)), 1, length(land.pools.cEco))
    p_F = copy(p_E)

    ## pack land variables
    @pack_land (p_E, p_F) => land.cFlowSoilProperties
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# precompute:
precompute/instantiate time-invariant variables for cFlowVegProperties_none


---

# Extended help
"""
cFlowVegProperties_none