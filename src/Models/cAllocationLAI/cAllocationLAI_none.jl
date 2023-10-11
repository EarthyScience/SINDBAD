export cAllocationLAI_none

struct cAllocationLAI_none <: cAllocationLAI end

function define(params::cAllocationLAI_none, forcing, land, helpers)

    ## calculate variables
    c_allocation_f_LAI = one(first(land.pools.cEco))

    ## pack land variables
    @pack_land c_allocation_f_LAI => land.cAllocationLAI
    return land
end

@doc """
sets the LAI effect on allocation to one (no effect)

# instantiate:

*Inputs*

*Outputs*
- land.cAllocationLAI.c_allocation_f_LAI: LAI effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationLAI_none
