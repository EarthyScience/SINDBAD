export cAllocationNutrients_none

struct cAllocationNutrients_none <: cAllocationNutrients end

function define(o::cAllocationNutrients_none, forcing, land, helpers)

    ## calculate variables
    minWLNL = helpers.numbers.𝟙

    ## pack land variables
    @pack_land minWLNL => land.cAllocationNutrients
    return land
end

@doc """
sets the pseudo-nutrient limitation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocationNutrients.minWLNL: Nutrient effect on cAllocation (0-1)
---

# Extended help
"""
cAllocationNutrients_none
