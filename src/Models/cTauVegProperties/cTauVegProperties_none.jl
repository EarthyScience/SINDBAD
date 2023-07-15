export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties end

function define(p_struct::cTauVegProperties_none, forcing, land, helpers)

    ## calculate variables
    p_k_f_veg_props = zero(land.pools.cEco) .+ one(eltype(land.pools.cEco))
    p_LITC2N = zero(first(land.pools.cEco))
    p_LIGNIN = zero(first(land.pools.cEco))
    p_MTF = one(first(land.pools.cEco))
    p_SCLIGNIN = zero(first(land.pools.cEco))
    p_LIGEFF = zero(first(land.pools.cEco))

    ## pack land variables
    @pack_land (p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_k_f_veg_props) => land.cTauVegProperties
    return land
end

@doc """
set the outputs to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauVegProperties_none


---

# Extended help
"""
cTauVegProperties_none
