export cAllocationSoilT_none

struct cAllocationSoilT_none <: cAllocationSoilT end

function precompute(o::cAllocationSoilT_none, forcing, land, helpers)

    ## calculate variables
    fT = helpers.numbers.one #sujan fsoilW was changed to fTSoil

    ## pack land variables
    @pack_land fT => land.cAllocationSoilT
    return land
end

@doc """
sets the temperature effect on allocation to one (no effect)

# precompute:

*Inputs*
- helpers.numbers.one

*Outputs*
- land.Radiation.fT: temperature effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationSoilT_none