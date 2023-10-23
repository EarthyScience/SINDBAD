export cAllocationNutrients_none

struct cAllocationNutrients_none <: cAllocationNutrients end

function define(params::cAllocationNutrients_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation_f_W_N = one(first(cEco))

    ## pack land variables
    @pack_nt c_allocation_f_W_N ⇒ land.diagnostics
    return land
end

@doc """
sets the pseudo-nutrient limitation to one (no effect)

# instantiate:

*Inputs*

*Outputs*
- land.diagnostics.c_allocation_f_W_N: Nutrient effect on cAllocation (0-1)
---

# Extended help
"""
cAllocationNutrients_none
