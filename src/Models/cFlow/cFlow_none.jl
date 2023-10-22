export cFlow_none

struct cFlow_none <: cFlow end

function define(params::cFlow_none, forcing, land, helpers)
    @unpack_land cEco ∈ land.pools
    ## calculate variables
    tmp = repeat(zero(cEco),
        1,
        1,
        length(cEco))
    c_flow_A_vec = tmp
    p_E_vec = tmp
    p_F_vec = tmp
    p_taker = []
    p_giver = []

    ## pack land variables
    @pack_land (c_flow_A_vec, p_E_vec, p_F_vec) → land.diagnostics
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered] set c_giver & c_taker matrices to [] get the transfer matrix transfers

# instantiate:
instantiate/instantiate time-invariant variables for cFlow_none


---

# Extended help
"""
cFlow_none
