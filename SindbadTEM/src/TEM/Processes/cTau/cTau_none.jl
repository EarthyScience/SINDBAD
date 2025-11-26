export cTau_none

struct cTau_none <: cTau end

function define(params::cTau_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_k = zero(cEco)

    ## pack land variables
    @pack_nt c_eco_k ⇒ land.diagnostics
    return land
end

purpose(::Type{cTau_none}) = "Sets the decomposition/turnover rates of all carbon pools to 0, i.e., no carbon decomposition and flow."

@doc """

$(getModelDocString(cTau_none))

---

# Extended help
"""
cTau_none
