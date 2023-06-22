export cAllocationRadiation_none

struct cAllocationRadiation_none <: cAllocationRadiation end

function define(o::cAllocationRadiation_none, forcing, land, helpers)

    ## calculate variables
    fR = helpers.numbers.𝟙

    ## pack land variables
    @pack_land fR => land.cAllocationRadiation
    return land
end

@doc """
sets the radiation effect on allocation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.Radiation.fR: radiation effect on cAllocation (0-1)


---

# Extended help
"""
cAllocationRadiation_none
