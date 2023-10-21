export cAllocation_none

struct cAllocation_none <: cAllocation end

function define(params::cAllocation_none, forcing, land, helpers)
    @unpack_land cEco ∈ land.pools

    ## calculate variables
    c_allocation = zero(cEco)

    ## pack land variables
    @pack_land c_allocation → land.diagnostics
    return land
end

@doc """
sets the carbon allocation to zero (nothing to allocated)

# instantiate:

*Inputs*

*Outputs*
- land.cAllocation.c_allocation: carbon allocation

---

# Extended help
"""
cAllocation_none
