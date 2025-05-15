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

purpose(::Type{cTauSoilW_none}) = "set the moisture stress for all carbon pools to ones"

@doc """

$(getModelDocString(cTauSoilW_none))

---

# Extended help
"""
cTauSoilW_none
