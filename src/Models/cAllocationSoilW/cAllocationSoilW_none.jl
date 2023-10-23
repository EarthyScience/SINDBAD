export cAllocationSoilW_none

struct cAllocationSoilW_none <: cAllocationSoilW end

function define(params::cAllocationSoilW_none, forcing, land, helpers)

    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation_f_soilW = one(first(cEco))

    ## pack land variables
    @pack_nt c_allocation_f_soilW ⇒ land.diagnostics
    return land
end

@doc """
sets the moisture effect on allocation to one (no effect)

# instantiate:

*Inputs*

*Outputs*
- land.diagnostics.c_allocation_f_soilW: moisture effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationSoilW_none
