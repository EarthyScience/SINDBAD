export cAllocationSoilT_none

struct cAllocationSoilT_none <: cAllocationSoilT end

function instantiate(o::cAllocationSoilT_none, forcing, land, helpers)

    ## calculate variables
    fT = helpers.numbers.𝟙 #sujan fsoilW was changed to fTSoil

    ## pack land variables
    @pack_land fT => land.cAllocationSoilT
    return land
end

@doc """
sets the temperature effect on allocation to one (no effect)

# instantiate:

*Inputs*
- helpers.numbers.𝟙

*Outputs*
- land.Radiation.fT: temperature effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationSoilT_none