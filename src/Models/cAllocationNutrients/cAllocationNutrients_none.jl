export cAllocationNutrients_none

struct cAllocationNutrients_none <: cAllocationNutrients end

function define(p_struct::cAllocationNutrients_none, forcing, land, helpers)

    ## calculate variables
    c_allocation_f_W_N = helpers.numbers.𝟙

    ## pack land variables
    @pack_land c_allocation_f_W_N => land.cAllocationNutrients
    return land
end

@doc """
sets the pseudo-nutrient limitation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocationNutrients.c_allocation_f_W_N: Nutrient effect on cAllocation (0-1)
---

# Extended help
"""
cAllocationNutrients_none
