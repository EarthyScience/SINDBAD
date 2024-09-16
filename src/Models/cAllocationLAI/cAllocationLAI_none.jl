export cAllocationLAI_none

struct cAllocationLAI_none <: cAllocationLAI end

function define(params::cAllocationLAI_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation_f_LAI = one(first(cEco))

    ## pack land variables
    @pack_nt c_allocation_f_LAI ⇒ land.diagnostics
    return land
end

@doc """
sets the LAI effect on allocation to one (no effect)

# instantiate:

*Inputs*

*Outputs*
- land.diagnostics.c_allocation_f_LAI: LAI effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationLAI_none
