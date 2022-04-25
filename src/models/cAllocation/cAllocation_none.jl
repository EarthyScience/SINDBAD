export cAllocation_none

struct cAllocation_none <: cAllocation end

function precompute(o::cAllocation_none, forcing, land, helpers)

    ## calculate variables
    cAlloc = zeros(helpers.numbers.numType, length(land.pools.cEco))

    ## pack land variables
    @pack_land cAlloc => land.states
    return land
end

@doc """
sets the carbon allocation to zero (nothing to allocated)

# precompute:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocation.cAlloc: carbon allocation

---

# Extended help
"""
cAllocation_none