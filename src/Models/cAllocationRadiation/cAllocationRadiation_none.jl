export cAllocationRadiation_none

struct cAllocationRadiation_none <: cAllocationRadiation end

function define(params::cAllocationRadiation_none, forcing, land, helpers)

    ## calculate variables
    c_allocation_f_cloud = one(first(land.pools.cEco))

    ## pack land variables
    @pack_land c_allocation_f_cloud → land.diagnostics
    return land
end

@doc """
sets the radiation effect on allocation to one (no effect)

# instantiate:

*Inputs*

*Outputs*
- land.diagnostics.c_allocation_f_cloud: radiation effect on cAllocation (0-1)


---

# Extended help
"""
cAllocationRadiation_none
