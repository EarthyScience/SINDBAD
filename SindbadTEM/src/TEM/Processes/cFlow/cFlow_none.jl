export cFlow_none

struct cFlow_none <: cFlow end

function define(params::cFlow_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools
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
    @pack_nt (c_flow_A_vec, p_E_vec, p_F_vec) ⇒ land.diagnostics
    return land
end

purpose(::Type{cFlow_none}) = "Sets carbon transfers between pools to 0 (no transfer); sets c_giver and c_taker matrices to empty; retrieves the transfer matrix."

@doc """

$(getProcessDocstring(cFlow_none))

---

# Extended help
"""
cFlow_none
