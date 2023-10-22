export cTauSoilProperties_none

struct cTauSoilProperties_none <: cTauSoilProperties end

function define(params::cTauSoilProperties_none, forcing, land, helpers)
    @unpack_land cEco ∈ land.pools

    ## calculate variables
    c_eco_k_f_soil_props = one.(cEco)

    ## pack land variables
    @pack_land c_eco_k_f_soil_props → land.diagnostics
    return land
end

@doc """
Set soil texture effects to ones (ineficient, should be pix zix_mic)

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilProperties_none


---

# Extended help
"""
cTauSoilProperties_none
