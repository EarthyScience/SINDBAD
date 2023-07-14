export cAllocationRadiation_none

struct cAllocationRadiation_none <: cAllocationRadiation end

function define(p_struct::cAllocationRadiation_none, forcing, land, helpers)

    ## calculate variables
    c_allocation_f_cloud = helpers.numbers.𝟙

    ## pack land variables
    @pack_land c_allocation_f_cloud => land.cAllocationRadiation
    return land
end

@doc """
sets the radiation effect on allocation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.Radiation.c_allocation_f_cloud: radiation effect on cAllocation (0-1)


---

# Extended help
"""
cAllocationRadiation_none
