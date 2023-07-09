export cAllocation_none

struct cAllocation_none <: cAllocation end

function define(p_struct::cAllocation_none, forcing, land, helpers)

    ## calculate variables
    c_allocation = zero(land.pools.cEco)

    ## pack land variables
    @pack_land c_allocation => land.states
    return land
end

@doc """
sets the carbon allocation to zero (nothing to allocated)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocation.c_allocation: carbon allocation

---

# Extended help
"""
cAllocation_none
