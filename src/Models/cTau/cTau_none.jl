export cTau_none

struct cTau_none <: cTau end

function define(params::cTau_none, forcing, land, helpers)

    ## calculate variables
    c_eco_k = one.(land.pools.cEco)

    ## pack land variables
    @pack_land c_eco_k => land.cTau
    return land
end

@doc """
set the actual τ to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTau_none


---

# Extended help
"""
cTau_none
