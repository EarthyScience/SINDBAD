export cTauSoilProperties_none

struct cTauSoilProperties_none <: cTauSoilProperties end

function define(params::cTauSoilProperties_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    ## calculate variables
    c_eco_k_f_soil_props = one.(cEco)

    ## pack land variables
    @pack_nt c_eco_k_f_soil_props ⇒ land.diagnostics
    return land
end

purpose(::Type{cTauSoilProperties_none}) = "Set soil texture effects to ones (ineficient, should be pix zix_mic)"

@doc """

$(getBaseDocString(cTauSoilProperties_none))

---

# Extended help
"""
cTauSoilProperties_none
