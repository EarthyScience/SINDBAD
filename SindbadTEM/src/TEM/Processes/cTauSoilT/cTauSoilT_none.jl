export cTauSoilT_none

struct cTauSoilT_none <: cTauSoilT end

function define(params::cTauSoilT_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_k_f_soilT = one(eltype(cEco))

    ## pack land variables
    @pack_nt c_eco_k_f_soilT ⇒ land.diagnostics
    return land
end

purpose(::Type{cTauSoilT_none}) = "Sets the effect of soil temperature on decomposition rates to 1 (no temperature effect)."

@doc """

$(getProcessDocstring(cTauSoilT_none))

---

# Extended help
"""
cTauSoilT_none
