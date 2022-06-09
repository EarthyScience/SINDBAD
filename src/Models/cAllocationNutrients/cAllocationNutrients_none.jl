export cAllocationNutrients_none

struct cAllocationNutrients_none <: cAllocationNutrients end

function precompute(o::cAllocationNutrients_none, forcing, land::NamedTuple, helpers::NamedTuple)

    ## calculate variables
    minWLNL = helpers.numbers.𝟙

    ## pack land variables
    @pack_land minWLNL => land.cAllocationNutrients
    return land
end

@doc """
sets the pseudo-nutrient limitation to one (no effect)

# precompute:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocationNutrients.minWLNL: Nutrient effect on cAllocation (0-1)
---

# Extended help
"""
cAllocationNutrients_none