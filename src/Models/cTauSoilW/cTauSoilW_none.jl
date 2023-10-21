export cTauSoilW_none

struct cTauSoilW_none <: cTauSoilW end

function define(params::cTauSoilW_none, forcing, land, helpers)

    ## calculate variables
    c_eco_k_f_soilW = one.(land.pools.cEco)

    ## pack land variables
    @pack_land c_eco_k_f_soilW → land.diagnostics
    return land
end

@doc """
set the moisture stress for all carbon pools to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilW_none


---

# Extended help
"""
cTauSoilW_none
