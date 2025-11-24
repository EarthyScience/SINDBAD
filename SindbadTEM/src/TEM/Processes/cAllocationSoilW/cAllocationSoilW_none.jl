export cAllocationSoilW_none

struct cAllocationSoilW_none <: cAllocationSoilW end

function define(params::cAllocationSoilW_none, forcing, land, helpers)

    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation_f_soilW = one(first(cEco))

    ## pack land variables
    @pack_nt c_allocation_f_soilW ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationSoilW_none}) = "Sets the moisture effect on allocation to 1 (no effect)."

@doc """

$(getProcessDocstring(cAllocationSoilW_none))

---

# Extended help
"""
cAllocationSoilW_none
