export cAllocationSoilW_none

struct cAllocationSoilW_none <: cAllocationSoilW end

function instantiate(o::cAllocationSoilW_none, forcing, land, helpers)

    ## calculate variables
    fW = helpers.numbers.𝟙

    ## pack land variables
    @pack_land fW => land.cAllocationSoilW
    return land
end

@doc """
sets the moisture effect on allocation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.cAllocationSoilW.fW: moisture effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationSoilW_none