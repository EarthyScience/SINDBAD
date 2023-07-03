export cFlow_none

struct cFlow_none <: cFlow end

function define(o::cFlow_none, forcing, land, helpers)

    ## calculate variables
    tmp = repeat(zeros(helpers.numbers.num_type, length(land.pools.cEco)),
        1,
        1,
        length(land.pools.cEco))
    p_A = tmp
    p_E = tmp
    p_F = tmp
    p_taker = []
    p_giver = []

    ## pack land variables
    @pack_land (p_A, p_E, p_F, p_giver, p_taker) => land.cFlow
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered] set giver & taker matrices to [] get the transfer matrix transfers

# instantiate:
instantiate/instantiate time-invariant variables for cFlow_none


---

# Extended help
"""
cFlow_none
