export cAllocationRadiation_none

struct cAllocationRadiation_none <: cAllocationRadiation end

function define(params::cAllocationRadiation_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation_f_cloud = one(first(cEco))

    ## pack land variables
    @pack_nt c_allocation_f_cloud ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationRadiation_none}) = "sets the radiation effect on allocation to one (no effect)"

@doc """

$(getBaseDocString(cAllocationRadiation_none))

---

# Extended help
"""
cAllocationRadiation_none
