export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties
end

function precompute(o::cTauVegProperties_none, forcing, land, helpers)
    @unpack_land (zero, numType) ∈ helpers.numbers

    ## calculate variables
    p_kfVeg = ones(numType, helpers.pools.carbon.nZix.cEco)
    p_LITC2N = zero
    p_LIGNIN = zero
    p_MTF = one
    p_SCLIGNIN = zero
    p_LIGEFF = zero

    ## pack land variables
    @pack_land (p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_kfVeg) => land.cTauVegProperties
    return land
end

@doc """
set the outputs to ones

# precompute:
precompute/instantiate time-invariant variables for cTauVegProperties_none


---

# Extended help
"""
cTauVegProperties_none