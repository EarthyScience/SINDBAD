export cTauSoilProperties_none

struct cTauSoilProperties_none <: cTauSoilProperties end

function define(p_struct::cTauSoilProperties_none, forcing, land, helpers)

    ## calculate variables
    c_eco_k_f_soil_props = zero(land.pools.cEco) .+ one(eltype(land.pools.cEco))

    ## pack land variables
    @pack_land c_eco_k_f_soil_props => land.cTauSoilProperties
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
