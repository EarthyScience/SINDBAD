export cTauSoilT_none

struct cTauSoilT_none <: cTauSoilT end

function define(params::cTauSoilT_none, forcing, land, helpers)

    ## calculate variables
    c_eco_k_f_soilT = one(eltype(land.pools.cEco))

    ## pack land variables
    @pack_land c_eco_k_f_soilT => land.cTauSoilT
    return land
end

@doc """
set the outputs to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilT_none


---

# Extended help
"""
cTauSoilT_none
