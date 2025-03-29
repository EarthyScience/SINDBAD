export cTau_none

struct cTau_none <: cTau end

function define(params::cTau_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_k = one.(cEco)

    ## pack land variables
    @pack_nt c_eco_k ⇒ land.diagnostics
    return land
end

purpose(::Type{cTau_none}) = "set the actual τ to ones"

@doc """

$(getBaseDocString(cTau_none))

---

# Extended help
"""
cTau_none
