export cTauLAI_none

struct cTauLAI_none <: cTauLAI end

function define(params::cTauLAI_none, forcing, land, helpers)

    ## calculate variables
    c_eco_k_f_LAI = one.(land.pools.cEco)

    ## pack land variables
    @pack_land c_eco_k_f_LAI → land.diagnostics
    return land
end

@doc """
set values to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauLAI_none


---

# Extended help
"""
cTauLAI_none
