export cAllocation_none

struct cAllocation_none <: cAllocation end

function define(params::cAllocation_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation = zero(cEco)

    ## pack land variables
    @pack_nt c_allocation ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocation_none}) = "sets the carbon allocation to zero (nothing to allocated)"

@doc """

$(getBaseDocString(cAllocation_none))

---

# Extended help
"""
cAllocation_none
