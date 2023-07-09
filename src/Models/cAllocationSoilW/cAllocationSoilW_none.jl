export cAllocationSoilW_none

struct cAllocationSoilW_none <: cAllocationSoilW end

function define(p_struct::cAllocationSoilW_none, forcing, land, helpers)

    ## calculate variables
    c_allocation_f_soilW = helpers.numbers.𝟙

    ## pack land variables
    @pack_land c_allocation_f_soilW => land.cAllocationSoilW
    return land
end

@doc """
sets the moisture effect on allocation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocationSoilW.c_allocation_f_soilW: moisture effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationSoilW_none
