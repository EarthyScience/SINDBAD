export cAllocationSoilT_none

struct cAllocationSoilT_none <: cAllocationSoilT end

function define(params::cAllocationSoilT_none, forcing, land, helpers)

    ## calculate variables
    c_allocation_f_soilT = one(first(land.pools.cEco)) #sujan fsoilW was changed to fTSoil

    ## pack land variables
    @pack_land c_allocation_f_soilT → land.diagnostics
    return land
end

@doc """
sets the temperature effect on allocation to one (no effect)

# instantiate:

*Inputs*

*Outputs*
- land.Radiation.c_allocation_f_soilT: temperature effect on cAllocation (0-1)

---

# Extended help
"""
cAllocationSoilT_none
