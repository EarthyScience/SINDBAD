export cAllocationLAI_none

struct cAllocationLAI_none <: cAllocationLAI end

function define(o::cAllocationLAI_none, forcing, land, helpers)

    ## calculate variables
    LL = helpers.numbers.𝟙

    ## pack land variables
    @pack_land LL => land.cAllocationLAI
    return land
end

@doc """
sets the LAI effect on allocation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocationLAI.LL: LAI effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationLAI_none
