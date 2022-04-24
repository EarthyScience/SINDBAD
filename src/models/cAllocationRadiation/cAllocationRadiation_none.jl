export cAllocationRadiation_none

struct cAllocationRadiation_none <: cAllocationRadiation end

function precompute(o::cAllocationRadiation_none, forcing, land, helpers)

    ## calculate variables
    fR = helpers.numbers.one

    ## pack land variables
    @pack_land fR => land.cAllocationRadiation
    return land
end

@doc """
sets the radiation effect on allocation to one (no effect)

# precompute:

*Inputs*
- helpers.numbers.one

*Outputs*
- land.Radiation.fR: radiation effect on cAllocation (0-1)


---

# Extended help
"""
cAllocationRadiation_none