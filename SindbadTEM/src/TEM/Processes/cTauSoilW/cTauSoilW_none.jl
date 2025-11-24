export cTauSoilW_none

struct cTauSoilW_none <: cTauSoilW end

function define(params::cTauSoilW_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_k_f_soilW = one.(cEco)

    ## pack land variables
    @pack_nt c_eco_k_f_soilW ⇒ land.diagnostics
    return land
end

purpose(::Type{cTauSoilW_none}) = "Sets the effect of soil moisture on decomposition rates to 1 (no moisture effect)."

@doc """

$(getProcessDocstring(cTauSoilW_none))

---

# Extended help
"""
cTauSoilW_none
