export cAllocationLAI_none

struct cAllocationLAI_none <: cAllocationLAI end

function precompute(o::cAllocationLAI_none, forcing, land, helpers)

    ## calculate variables
    LL = helpers.numbers.one

    ## pack land variables
    @pack_land LL => land.cAllocationLAI
    return land
end

@doc """
sets the LAI effect on allocation to one (no effect)

# precompute:

*Inputs*
- helpers.numbers.one

*Outputs*
- land.cAllocationLAI.LL: LAI effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationLAI_none