export cAllocationNutrients_none

struct cAllocationNutrients_none <: cAllocationNutrients end

function define(params::cAllocationNutrients_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_allocation_f_W_N = one(first(cEco))

    ## pack land variables
    @pack_nt c_allocation_f_W_N ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationNutrients_none}) = "sets the pseudo-nutrient limitation to one (no effect)"

@doc """

$(getModelDocString(cAllocationNutrients_none))

---

# Extended help
"""
cAllocationNutrients_none
